
.section .data

    .globl HEAP_START_ADDR
    .globl CURRENT_BREAK_ADDR

    HEAP_START_ADDR:
        .long 0

    CURRENT_BREAK_ADDR:
        .long 0

# Stack location of the required size thats passed as
# argument to the allocate function.
.equ STACK_ALLOC_REQ_SIZE, 8


.section .text

    .globl allocate_init
    .type allocate_init, @function
    allocate_init:

        pushl %ebp
        movl %esp, %ebp

        # Call brk syscall with 0 argument to get current break address
        # and initial heap start address
        movl $0, %ebx
        movl $SYSCALL_BRK, %eax
        int $LINUX_SYSCALL

        incl %eax # Next address will be unused address

        movl %eax, $CURRENT_BREAK_ADDR
        movl %eax, $HEAP_START_ADDR

        movl %ebp, %esp
        popl %ebp


    .globl allocate
    .type allocate, @function
    allocate:

        pushl %ebp
        movl %esp, %ebp

        movl STACK_ALLOC_REQ_SIZE(%ebp), %ecx

        movl %ebp, %esp
        popl %ebp