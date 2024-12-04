.global _start
.global print_string
.align 2

_start:

    // Main loop
    loop:
        // Reset screen
        adr x1, clear_screen_msg
        mov x2, clear_screen_len
        bl print_string
    
        // Draw block
        adr x1, block
        mov x2, block_len
        bl print_string
    b loop

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

msg: .ascii "Message\n"
msg_len = . - msg
msg2: .ascii "Message 2\n"
msg2_len = . - msg2
block: .asciz "█"
block_len = . - block

clear_screen_msg:
    .asciz "\033[2J\033[H"          // Clear screen and move cursor to top-left
clear_screen_len = . - clear_screen_msg
