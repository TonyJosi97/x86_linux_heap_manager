mkdir -p build
cd build
as ../src/allocate.s -o allocate.o --32 -I ../inc
as ../src/deallocate.s -o deallocate.o --32 -I ../inc
as ../test/test.s -o test.o --32 -I ../inc
ld -dynamic-linker /lib/ld-linux.so.2 allocate.o deallocate.o test.o -o hp_test -lc -m elf_i386
