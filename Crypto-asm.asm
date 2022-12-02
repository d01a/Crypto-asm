



.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:dword

.data 
S			db		256 dup(?)				; Declaring uninitialized 256 char
key			DB		"Secret",0
key_Length	DB		6
i			DW		?
j			DW		?

.code 

main PROC

	call RC4_Init

	invoke ExitProcess,0
main endp

;RC4_Init Procedure start

RC4_Init PROC

		COMMENT ^
		for (i = 0; i < 256; i++)
        S[i] = i;
		^

		mov edi, OFFSET S		;Storing the start address of the array in the index register DI
		mov ecx, 256			;storing the length of the array in ecx for loop iterations
		mov eax, 0				;counter

	L1:
		mov [edi],al			;Storing the value of i to the ith element in the array
		add edi, TYPE S			;TYPE (Return the size of a single element in the array) so we move to the next element in the array
		inc al					;increment counter
		loop L1					;jump to the loop untill we make 256 iterations to break


		COMMENT ^
		for (i = j = 0; i < 256; i++) {
			j = (j + key[i % key_length] + S[i]) & 255;
		    swap(S, i, j);
		}
		^
		mov edi, OFFSET S		;Storing the start address of the array in the index register DI
		mov esi, OFFSET key
		mov eax, 0
		mov ebx, 0
		mov cx, LENGTHOF S		;initialize ecx with the number of elements  in the array

	L2:
		mov ax,  i				;move the value of i to AX to be divided with key length and the value of the remainder will be stored in AH so shift right it with 8
		div key_Length			;divide i with the keylength length 
		shr ax, 8				;move the remainder to al
		mov bl ,[edi]			;as we can't make a memory to memory transfer, use register as a temp
		add j, bx				; j = S[i] 
		mov bl ,[esi + eax]	;	
		add j,	bx				; j = S[i] + key[i%key_length] 
		and j,	255				; j = j & 255
		add edi, TYPE S			; &S[i+1]
		cmp i, cx				;check if the value of i reached its limit (256) if it reached Zero flag will be set
		pusha
		call Swap
		popa
		inc i					;increment i 
		
		jnz L2					;check if zero flag isn't set to jump to L2,if set it will continue to the next instruction
		
		COMMENT ^
			i = j = 0;
		^

		mov i, 0				;i = 0
		mov j, 0				;j = 0
		ret
RC4_Init ENDP
;RC4_Init Procedure end

swap PROC
	mov edi,OFFSET S
	mov ebx,0
	mov edx,0
	mov bx,j
	mov dx,i
	mov al,[edi + edx]    
	xchg al,[edi + ebx]
	mov [edi + edx], al
	ret


swap ENDP
Swap PROC
        
		 mov edi, OFFSET S   ;Storing the start address of the array in the index register DI
		 ;Make sure that all regs are empty
		 mov ebx,0            
		 mov edx,0
		 mov cx,0
		 mov ax,0
		 ;get the indexes we want to swap
		 mov bx, i         
		 mov dx, j
	     mov al, [edi+ebx]   ;temp=s[i]
	     ;s[i]=s[j]
		 mov cl,[edi+edx]    
	     mov [edi+ebx],cl
	     mov [edi+edx],al   ;s[j]=temp
         ret
Swap ENDP
end main
