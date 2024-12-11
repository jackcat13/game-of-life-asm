.global _start
.global print_string
.align 2

_start:
    game_loop:
        display:
            mov x3, #0 // x
            mov x4, #0 // y
            // Reset screen
            adr x1, clear_screen_msg
            mov x2, clear_screen_len
            bl print_string
            
            display_loop_y:
                display_loop_x:
                    // Draw block
                    adr x1, block
                    mov x2, block_len
                    bl print_string
                
                // while x < max_width
                adr x5, max_width
                add x3, x3, #1
                cmp x3, x5
                b.lt display_loop_x
                
                // Display new line
                adr x1, new_line
                mov x2, new_line_len
                bl print_string
                
            // while y < max_height
            adr x5, max_height
            add x4, x4, #1
            cmp x4, x5
            b.lt display_loop_y
    
    
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

max_width: .word 200
max_height: .word 50

block: .asciz "█"
block_len = . - block
new_line: .ascii "\n"
new_line_len = . - new_line

clear_screen_msg:
    .asciz "\033[2J\033[H"          // Clear screen and move cursor to top-left
clear_screen_len = . - clear_screen_msg
