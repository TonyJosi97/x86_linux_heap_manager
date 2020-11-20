.include "linux_asm_defs.s"
.include "heap_memory_header_struct.s"


.section .data

    .globl HEAP_START_ADDR
    .globl CURRENT_BREAK_ADDR

    HEAP_START_ADDR:
        .long 0

    CURRENT_BREAK_ADDR:
        .long 0

# Stack location of the required size thats passed as
# argument to the allocate function.
.equ STACK_ALLOC_REQ_SIZE,                  8


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
        movl $HEAP_START_ADDR, %eax
        movl $CURRENT_BREAK_ADDR, %ebx

        loop_search_unallocated_mem_begin:

            cmpl %ebx, %eax
            je request_more_mem_from_OS

            movl HP_MEM_HEADER_ALLOC_SIZE_OFFSET(%eax), %edx

            cmpl $ALLOCATED, HP_MEM_HEADER_ALLOC_FLAG_OFFSET(%eax)
            je move_to_next_location

            cmpl %edx, %ecx
            jle allocate_mem

            move_to_next_location:
                addl $HP_MEM_HEADER_SIZE, %eax
                addl %edx, %eax
                jmp loop_search_unallocated_mem_begin

        allocate_mem:
            movl $ALLOCATED, HP_MEM_HEADER_ALLOC_FLAG_OFFSET(%eax)
            addl $HP_MEM_HEADER_SIZE, %eax
            movl %ebp, %esp
            popl %ebp             
            ret

        request_more_mem_from_OS:
            addl $HP_MEM_HEADER_SIZE, %ebx      # Include the header size
            addl %ecx, %ebx                     # Total requested memory

            movl $SYSCALL_BRK, %eax

            # Save registers
            pushl %eax
            pushl %ebx
            pushl %ecx
            
            int $LINUX_SYSCALL

            cmpl $0 ,%eax
            je brk_error

            popl %ecx
            popl %ebx
            popl %eax                           # Not interested in the new breakpoint

            movl $ALLOCATED, HP_MEM_HEADER_ALLOC_FLAG_OFFSET(%eax)
            movl %ecx, HP_MEM_HEADER_ALLOC_SIZE_OFFSET(%eax)

            addl $HP_MEM_HEADER_SIZE, %eax
            movl %ebx, $CURRENT_BREAK_ADDR

            movl %ebp, %esp
            popl %ebp
            ret

        brk_error:
            movl $0, %eax
            movl %ebp, %esp
            popl %ebp
            ret
