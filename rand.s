.global xorshift

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