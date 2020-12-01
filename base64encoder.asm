; Executable name : base64encoder
; Created         : 30/11/2020
; Last updated	  : 
; Description	  : A simple program in assembly that can encodes binary values to base64.

; Important registers:
; r10 holds the first byte
; r11 holds the second byte
; r12 holds the third byte


SECTION .data

    ; Base64 Base64Table Implementation
    Base64Table:         db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    ; Initialize a buffer for writing to stdout
    Result:         db "0000"
    ResultLength:      equ $-Result
	
	; CONSTANTS
	
	SYS_READ	equ 0
	SYS_WRITE		equ 1
	SYS_EXIT	equ 60
	STDIN			equ 0
	STDOUT		equ 1

    
SECTION .bss

    ; Reserve a buffer for reading from stdin
    BufferLength:       equ 3
    Buffer:          resb BufferLength

SECTION .text			; Section containing code
global 	_start			; Linker needs this to find the entry point!

_start:
     
read:
    
    mov rax, SYS_READ                      ; code for system read call
    mov rdi, STDIN                      ; standard Input
    mov rsi, Buffer                  ; destination buffer
    mov rdx, BufferLength               ; maximum number of bytes to read
    syscall
    
	;xor r10, r10
	;xor r11, r11
	xor r12, r12

    cmp rax, 0                      ; did we receive any bytes?
    je exit                         ; if not: exit the program

    ; Prepare registers for loop
    cmp rax, 1                      ; compares value of r11 with 1
	je convertOneByte			; if the value equals 1, jump to the convertOneByte procedure
	
    cmp rax, 2                      ; compares value of r11 with 2
    je convertTwoBytes			; if the value equals 2, jump to the convertTwoBytes procedure
	
	jmp convertThreeBytes	; if the value greater or equals 3, jump to the convertThreeBytes procedure
    
	
convertOneByte:  

    ; Read a single byte from Buffer and store it to rax and rbx
    mov al, byte [Buffer]            ; from memory: copy 1st byte to rax
    mov r10, rax                    ; from rax: copy 1st byte to r10
    
   
    mov rax, r10                    ; copy r10 to rax
    and al, 0fch                    ; mask out the last 2 bits from right
    shr al, 2h                       ; get rid of the 2 last bits from right
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result], al        ; insert into Result

    mov rax, r10                    ; copy r10 to rax
    and al, 3h                    ; mask out the last 2 bits from right
    shl al, 4h                       ; multiply by 4
    shr bl, 4h                       ; divide by 4
    or al, bl                       						; merge al and bl
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result + 1], al      ; insert into Result
    
    mov byte [Result + 2], "="     ; insert into Result
    mov byte [Result + 3], "="     ; insert into Result
    
    jmp print

convertTwoBytes:
   ; Read a single byte from Buffer and store it to rax and rbx
    mov al, byte [Buffer]            ; from memory: copy 1st byte to rax
    mov r10, rax                    ; from rax: copy 1st byte to r10

    mov al, byte [Buffer + 1]          ; from memory: copy 2nd byte to rax
    mov r11, rax                    ; from rax: copy 2nd byte to r11
    
    ; extract 6 bit chunks
    mov rax, r10                    ; copy r10 to rax
    and al, 0fch                   ; mask out the last 2 bits from right
    shr al, 2h                       ; get rid of the 2 last bits from right
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result], al        ; insert into Result

    mov rax, r10                    ; copy r10 to rax
    mov rbx, r11                    ; copy r11 to rbx
    and al, 3h                    ; mask out the last 2 bits from right
    shl al, 4h                       ; multiply by 4
    shr bl, 4h                       ; divide by 4
    or al, bl                       ; merge al and bl
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result+1], al      ; insert into Result

    mov rax, r11                    ; copy r11 to rax 
    mov rbx, r12                    ; copy r12 to rbx
    and rax, 0fh                   ; mask out the last 4 bits from left
    shl rax, 2h                      ; add 2 additional bits from right
    and rbx, 0c0h                   ; mask out the first 2 bits from left
    shr rbx, 6h                      ; add 6 additional bits from left
    or rax, rbx                     ; merge rax and rbx
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result + 2], al      ; insert into Result
    
    mov byte [Result + 3], "="     ; insert into Result
    
    jmp print
	
	
	convertThreeBytes:
    
    mov al, byte [Buffer]            ; copy the first byte from memory to rax
    mov r10, rax                    ; copy the first byte from rax to r10

    mov al, byte [Buffer+1]          ;copy the second byte from memory to rax
    mov r11, rax                    ; copy the second byte from rax to r11

    mov al, byte [Buffer+2]          ; copy the third byte from memory to rax
    mov r12, rax                    ; copy the third by from rax to r12
    
    mov rax, r10                    ; copy r10 to rax
    and al, 0fch                    ; mask out the last 2 bits from right
    shr al, 2h                       ; get rid of the 2 last bits from right
    mov al, byte [Base64Table + rax]        ; loop up the corresponding base64 letter
    mov byte [Result], al        ; insert into Result

    mov rax, r10                    ; copy r10 to rax
    mov rbx, r11                    ; copy r11 to rbx
    and al, 3h                    ; mask out the last 2 bits from right
    shl al, 4h                       ; multiply by 4 
    shr bl, 4h                       ; divide by 4
    or al, bl                       ; merge al and bl
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result + 1], al      ; insert into Result

    mov rax, r11                    ; copy r11 to rax 
    mov rbx, r12                    ; copy r12 to rbx
    and rax, 0fh                   ; mask out the last 4 bits from left
    shl rax, 2h                      ; multiply by 2
    and rbx, 0c0h                   ; mask out the first 2 bits from left
    shr rbx, 6h                      ; divide by 6
    or rax, rbx                     ; merge rax and rbx
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result+2], al      ; insert into Result

    mov rax, r12                    ; copy r12 to rax
    and rax, 3fh                   ; mask out the last 6 bits from right
    mov al, byte [Base64Table + rax]        ; look up base64 letter
    mov byte [Result + 3], al      ; insert into Result
    
    jmp print

print:

    mov rax, SYS_WRITE                      ; sys_print
    mov rdi, STDOUT                      ; file descriptor: stdout
    mov rsi, Result              ; source buffer
    mov rdx, ResultLength           ; # of bytes to print
    syscall

    ; Go back to read the next bytes from input
    jmp read

exit:

    mov rax, SYS_EXIT                     ; code for sys_exit
    mov rdi, 0                      ; return 0
    syscall                         ; make kenell call 