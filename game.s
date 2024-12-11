.global _start
.global print_string
.align 2

_start:
    adr x1, init_game_message
    mov x2, init_game_message_len
    bl print_string
    
    ldr x13, =max_width
    ldr x14, =max_height

    game_init:
        // Create game array
        mov x0, #8 // array type: 8 bytes TODO : try to move to 4 bits everywhere
        mul x0, x0, x13
        mul x0, x0, x14
        sub sp, sp, x0 // Array allocation for the grid (8 bytes per cell) in stack
        mov x20, sp
        
        // Init values of array
        mov x3, #0 // counter
        array_init_loop:
            mov x1, #1
            str x1, [x20, x3]
        
        add x3, x3, #4
        cmp x3, x0
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
            
            mov x3, #0 // x
            mov x4, #0 // y
            
            display_loop_y:
                display_loop_x:
                    // Check if block should be printed by getting array element at good position
                    mov x9, #8
                    mov x6, x3
                    mul x6, x6, x9 // x * 8
                    mov x7, x4
                    mul x7, x7, x13 // y * max_width to resolve next line
                    mul x7, x7, x9 // * 8
                    add x6, x6, x7 // x + processedY
                    ldr x11, [x20, x6] // Get array element
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
                add x3, x3, #1
                cmp x3, x13
                b.lt display_loop_x
                
                // Display new line
                adr x1, new_line
                mov x2, new_line_len
                bl print_string
                
            // while y < max_height
            add x4, x4, #1
            cmp x4, x14
            b.lt display_loop_y
    
    
        // Wait for 100ms
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

max_width: .word 50
max_height: .word 50

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
