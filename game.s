.global _start
.global print_string
.align 2

_start:
    adr x1, init_game_message
    mov x2, init_game_message_len
    bl print_string
    
    mov x13, #32
    mov x14, #32

    game_init:
        // Create game array
        mov x10, #8 // array type: 8 bytes TODO : try to move to 4 bits everywhere
        mul x10, x10, x13
        mul x10, x10, x14
        sub sp, sp, x10 // Array allocation for the grid (8 bytes per cell) in stack
        mov x20, sp
        
        // Init values of array
        mov x17, #0 // counter
        array_init_loop:
            mov x8, #1
            str x8, [x20, x17]
        
        // While counter < max_width * max_height * size   
        add x17, x17, #8
        cmp x17, x10
        b.lt array_init_loop
    
    adr x1, init_game_done_message
    mov x2, init_game_done_message_len
    bl print_string
        
    game_loop:
        display:
            // Reset screen
            adr x1, clear_screen_msg
            mov x2, clear_screen_len
            bl print_string
            
            mov x17, #0 // x
            mov x18, #0 // y
            mov x19, #0 // counter
            
            display_loop_y:
                display_loop_x:
                    // Check if block should be printed by getting array element at good position
                    ldr x11, [x20, x19] // Get array element
                    add x19, x19, #8 // Increment counter
                    cmp x11, #1
                    b.eq print_block
                    
                    print_empty:
                        // Draw empty
                        adr x1, empty
                        mov x2, empty_len
                        b print_current
                    
                    print_block:
                        // Draw block
                        adr x1, block
                        mov x2, block_len
                        b print_current
                        
                    print_current:
                        bl print_string
                        
                // while x < max_width
                add x17, x17, #1
                cmp x17, x13
                b.lt display_loop_x
                
                mov x17, 0
                
                // Display new line
                adr x1, new_line
                mov x2, new_line_len
                bl print_string
                
            // while y < max_height
            add x18, x18, #1
            cmp x18, x14
            b.lt display_loop_y
    
    
        // Wait for 1s
        sub sp, sp, #16 // 16 bytes (8 bytes for tv_sec, 8 bytes for tv_nsec)
        mov x0, #1
        str x0, [sp] // tv_sec
        mov x0, #0 // nanosec
        str x0, [sp, #8] // tv_nsec
        mov x0, sp // Pointer to timespec struct
        mov x1, #0 // NULL pointer for remaining time$
        mov x16, #340 // syscall number for nanosleep
        svc #0x80
        add sp, sp, #16 // Restore stack pointer to deallocate timespec struct
            
    // while true        
    b game_loop

    // Terminate program with return code 0
    mov x0, #0
    mov x16, #1
    svc #0x80

// params : adr x1 : message address; mov x2 : message length
print_string:
    mov x0, #1
    mov x16, #4
    svc #0x80
    ret

    
// Static variables

max_width: .word 32
max_height: .word 32

block: .ascii "❂"
block_len = . - block
empty: .ascii " "
empty_len = . - empty
new_line: .ascii "\n"
new_line_len = . - new_line

init_game_message: .asciz "Init game\n"
init_game_message_len = . - init_game_message
init_game_done_message: .asciz "Init game done\n"
init_game_done_message_len = . - init_game_done_message

clear_screen_msg:
    .asciz "\033[2J\033[H"          // Clear screen and move cursor to top-left
clear_screen_len = . - clear_screen_msg
