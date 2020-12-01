base64encoder: base64encoder.o
	ld -o base64encoder base64encoder.o

base64encoder.o: base64encoder.asm
	nasm -f elf64 -g -F dwarf base64encoder.asm -l base64encoder.lst
run: base64encoder
	make clean && make && echo "" && ./base64encoder < Makefile && echo "" && echo "" && base64 -w0 < Makefile && echo "" && echo "" && ./base64encoder < 255.txt && echo "" && echo "" && base64 -w0 < 255.txt && echo "" && echo "" && ./base64encoder < 256.txt && echo "" && echo "" && base64 -w0 < 256.txt && echo "" && echo "" && ./base64encoder < 257.txt && echo "" && echo "" && base64 -w0 < 257.txt 

clean:
	rm -f base64encoder base64encoder.o base64encoder.lst
