lib.o: lib.asm
	nasm -g lib.asm -felf64 -o lib.o

dict.o: dict.asm
	nasm -g dict.asm -felf64 -o dict.o

main.o: main.asm words.inc colon.inc
	nasm -g main.asm -felf64 -o main.o

main: main.o lib.o dict.o
	ld -o main lib.o dict.o main.o

program: main
	./main
