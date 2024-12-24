.global _start
.global print_string
.extern _nanosleep
.extern _time
.align 2

_start:
    adr x1, init_game_message
    mov x2, init_game_message_len
    bl print_string
    
    mov x13, #100
    mov x14, #20
    mov x25, #130 // Seed for RNG

    game_init:
        // Create game array
        mov x10, #8 // array type: 8 bytes
        mul x10, x10, x13
        mul x10, x10, x14
        sub sp, sp, x10 // Array allocation for the grid (8 bytes per cell) in stack
        mov x20, sp
        sub sp, sp, x10 // Array allocation for the grid for next generation(8 bytes per cell) in stack
        mov x15, sp
        
        // Init values of array
        mov x17, #0 // counter
        array_init_loop:
            // Xorshift RNG using x25 as seed and store in array mod 2
            mov x0, x25
            bl xorshift
            mov x25, x0
            mov x7, #2
            udiv x2, x0, x7
            mul x3, x2, x7
            sub x0, x0, x3 // Now x0 contains the result of x0 % 2
            str x0, [x20, x17]
            str x0, [x15, x17]
        
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
                        
                    add x19, x19, #8 // Increment counter
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
    
    
        // Allocate timespec structure on the stack
        sub sp, sp, #16           // Reserve 16 bytes for `struct timespec`
        mov x0, sp                // Load address of timespec into x0
    
        // Set up timespec for 1 second (1s = 1,000,000,000ns)
        mov x1, #0                // set tv_sec
        str x1, [x0, #0]          // Store tv_sec at offset 0
        ldr x1, =100000000                // set tv_nsec
        str x1, [x0, #8]          // Store tv_nsec at offset 8
    
        // Call nanosleep
        mov x1, #0                // Set rmtp to NULL (no remaining time)
        bl _nanosleep             // Call nanosleep(struct timespec*, NULL)
    
        // Restore stack
        add sp, sp, #16           // Deallocate timespec structure
        
        // To check if each cell is alive or dead
        game_round:
            mov x17, #0 // x
            mov x18, #0 // y
            mov x19, #0 // counter
            mov x21, #0 // alive neighbours counter
            
            round_loop_y:
                round_loop_x:
                    mov x21, #0 // alive neighbours counter
                    
                    // -1, -1
                    check_x_minus_y_minus:
                        sub x22, x17, #1
                        sub x23, x18, #1
                        cmp x22, #0
                        b.lt check_x_y_minus
                        cmp x23, #0
                        b.lt check_x_y_minus
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq check_x_y_minus
                        add x21, x21, #1
                    
                    // 0, -1
                    check_x_y_minus:
                        mov x22, x17
                        sub x23, x18, #1
                        cmp x23, #0
                        b.lt check_x_plus_y_minus
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq check_x_plus_y_minus
                        add x21, x21, #1
                    
                    // 1, -1
                    check_x_plus_y_minus:
                        add x22, x17, #1
                        sub x23, x18, #1
                        cmp x22, x13
                        b.ge check_x_minus_y
                        cmp x23, #0
                        b.lt check_x_minus_y
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq check_x_minus_y
                        add x21, x21, #1
                    
                    // -1, 0
                    check_x_minus_y:
                        sub x22, x17, #1
                        mov x23, x18
                        cmp x22, #0
                        b.lt check_x_plus_y
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq check_x_plus_y
                        add x21, x21, #1
                    
                    // 1, 0
                    check_x_plus_y:
                        add x22, x17, #1
                        mov x23, x18
                        cmp x22, x13
                        b.ge check_x_minus_y_plus
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq check_x_minus_y_plus
                        add x21, x21, #1
                    
                    // -1, 1
                    check_x_minus_y_plus:
                        sub x22, x17, #1
                        add x23, x18, #1
                        cmp x22, #0
                        b.lt check_x_y_plus
                        cmp x23, x14
                        b.ge check_x_y_plus
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq check_x_y_plus
                        add x21, x21, #1
                    
                    // 0, 1
                    check_x_y_plus:
                        mov x22, x17
                        add x23, x18, #1
                        cmp x23, x14
                        b.ge check_x_plus_y_plus
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq check_x_plus_y_plus
                        add x21, x21, #1
                    
                    // 1, 1
                    check_x_plus_y_plus:
                        add x22, x17, #1
                        add x23, x18, #1
                        cmp x22, x13
                        b.ge alive_not_alive_checks
                        cmp x23, x14
                        b.ge alive_not_alive_checks
                        bl resolve_table_value
                        cmp x27, #0
                        b.eq alive_not_alive_checks
                        add x21, x21, #1
                        
                    alive_not_alive_checks:
                    ldr x12, [x20, x19] // Get current cell value
                    cmp x12, #1
                    b.eq alive
                    
                    not_alive:
                        mov x0, #3
                        cmp x21, x0
                        b.ne no_change
                        mov x1, #1
                        str x1, [x15, x19]
                        b end_round_loop
                    
                    alive:
                        mov x0, #2
                        cmp x21, x0
                        b.eq no_change
                        mov x0, #3
                        cmp x21, x0
                        b.eq no_change
                        mov x1, #0
                        str x1, [x15, x19]
                        b end_round_loop
                        
                    no_change:
                    end_round_loop:
                        add x19, x19, #8 // Increment counter
                        
                // while x < max_width
                add x17, x17, #1
                cmp x17, x13
                b.lt round_loop_x
                
            mov x17, 0
            
            // while y < max_height
            add x18, x18, #1
            cmp x18, x14
            b.lt round_loop_y
            
        // To apply round modifications
        game_round_apply:
            mov x17, #0 // x
            mov x18, #0 // y
            mov x19, #0 // counter
            
            round_loop_apply_y:
                round_loop_apply_x:
                    ldr x11, [x15, x19] // Get array element of next generation
                    str x11, [x20, x19] // Copy value to original array
                
                    add x19, x19, #8 // Increment counter
                // while x < max_width
                add x17, x17, #1
                cmp x17, x13
                b.lt round_loop_apply_x
            
            mov x17, 0
            
            // while y < max_height
            add x18, x18, #1
            cmp x18, x14
            b.lt round_loop_apply_y
            
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
    
resolve_table_value:
    mov x0, #8
    mul x22, x22, x0
    mul x0, x0, x13
    mul x23, x23, x0
    add x24, x22, x23
    ldr x27, [x20, x24]
    ret
    
// Static variables

max_width: .word 32
max_height: .word 32

block: .ascii "█"
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

format_string: .asciz "Value: %d\n"  // Format string for printing integers
