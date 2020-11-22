.include "linux_asm_defs.s"
.include "heap_memory_header_struct.s"

.section .data

    alloc_status:
        .ascii "Allocation Done\n\0"

    dealloc_status:
        .ascii "Deallocation Done\n\0"

    alloc_fail:
        .ascii "Allocation Fail\n\0"

.section .text

    .globl _start
    _start:

        pushl %ebp
        movl %esp, %ebp

        call allocate_init
        
        pushl $24
        call allocate
        addl $4, %esp

        cmpl $0, %eax
        je print_alloc_fail

        pushl %eax
        pushl $alloc_status
        call printf
        addl $4, %esp
        popl %eax
        
        pushl %eax
        call deallocate
        addl $4, %esp

        pushl $dealloc_status
        call printf
        addl $4, %esp

        prog_exit:
            movl %ebp, %esp
            popl %ebp
            pushl $0
            call exit

        print_alloc_fail:
            pushl $alloc_fail
            call printf
            addl $4, %esp
            jmp prog_exit
        
