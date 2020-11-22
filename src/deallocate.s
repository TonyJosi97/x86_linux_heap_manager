.include "linux_asm_defs.s"
.include "heap_memory_header_struct.s"

.section .text

    .globl deallocate
    .type deallocate, @function

    .equ STACK_MEM_SEGMENT, 8

    deallocate:

        pushl %ebp
        movl %esp, %ebp

        movl STACK_MEM_SEGMENT(%ebp), %eax
        subl $HP_MEM_HEADER_SIZE, %eax

        movl $UNALLOCATED, HP_MEM_HEADER_ALLOC_FLAG_OFFSET(%eax)

        movl %ebp, %esp
        popl %ebp
        ret
