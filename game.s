.global _start
.global print_string
.extern _sleep
.extern _time
.align 2

_start:
    adr x1, init_game_message
    mov x2, init_game_message_len
    bl print_string
    
    mov x13, #32
    mov x14, #32
    mov x25, #4211 // Seed for RNG

    game_init:
        // Create game array
        mov x10, #8 // array type: 8 bytes TODO : try to move to 4 bytes everywhere
        mul x10, x10, x13
        mul x10, x10, x14
        sub sp, sp, x10 // Array allocation for the grid (8 bytes per cell) in stack
        mov x20, sp
        
        // Init values of array
        mov x17, #0 // counter
        array_init_loop:
            // Xorshift RNG using x25 as seed and store in array mod 2
            mov x0, x25
            bl xorshift
            mov x25, x0
            mov x7, #4
            udiv x2, x0, x7
            mul x3, x2, x7
            sub x0, x0, x3 // Now x0 contains the result of x0 % 4
            str x0, [x20, x17]
        
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
        mov x0, #1
        bl _sleep
            
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

//params : x0 : seed, return x0 : random number
xorshift:
    mov x1, #21
    mov x2, #35
    mov x3, #4
    mov x4, x0
    lsl x0, x0, x1
    eor x0, x0, x4
    lsr x4, x0, x2
    eor x0, x0, x4
    lsl x4, x0, x3
    eor x0, x0, x4
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
