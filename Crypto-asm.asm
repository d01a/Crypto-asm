



.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:dword

.data 
S			db		256 dup(?)				; Declaring uninitialized 256 char
key			DB		"Secret",0
plaintext	DB		256 dup(?)
ciphertext	DB		256 dup(?)
key_Length	DB		6
i			DW		?
j			DW		?

.code 

main PROC

	call RC4_Init
	call RC4_Output
	pop ax
	

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
		mov i,0
		mov j,0
		mov cx, LENGTHOF S		;initialize ecx with the number of elements  in the array

	L2:
		mov ax,  i				;move the value of i to AX to be divided with key length and the value of the remainder will be stored in AH so shift right it with 8
		;call strlen
		div key_Length			;divide i with the keylength length 
		
		shr ax, 8				;move the remainder to al
		mov bl ,[edi]			;as we can't make a memory to memory transfer, use register as a temp bl = S[i]
		add j, bx				; j = j + S[i] 
		mov bl ,[esi + eax]		; bl = 	key[i%key_length]
		add j,	bx				; j = S[i] + key[i%key_length] + j
		and j,	255				; j = j & 255
		add edi, TYPE S			; &S[i+1]
		pusha
		call swap
		popa
		inc i					;increment i 
		cmp i, cx				;check if the value of i reached its limit (256) if it reached Zero flag will be set
		jnz L2					;check if zero flag isn't set to jump to L2,if set it will continue to the next instruction
		
		COMMENT ^
			i = j = 0;
		^

		ret
RC4_Init ENDP
;RC4_Init Procedure end


Swap PROC
        
		 mov edi, OFFSET S				;Storing the start address of the array in the index register DI
										;Make sure that all regs are empty
		 mov ebx,0            
		 mov edx,0
		 mov cx,0
		 mov ax,0
										;get the indexes we want to swap
		 mov bx, i         
		 mov dx, j
	     mov al, [edi+ebx]				;temp=s[i]
	     ;s[i]=s[j]
		 mov cl,[edi+edx]    
	     mov [edi+ebx],cl
	     mov [edi+edx],al				;s[j]=temp
         ret
Swap ENDP

RC4_Output PROC
		mov i, 0						;i = 0
		mov j, 0						;j = 0
		lea edi, S
		xor eax,eax
		xor ebx,ebx
		call strlen
		mov ecx,eax						;store length of text in ecx
		xor edx, edx					;n (counter)
	L_Out:
		mov ax, i
		mov bx, j

		inc i							;i = i + 1
		and i, 255						;i = (i + 1) & 255	
		
		mov ax, i						;ax=i
		mov j, bx						;j = bx
		add bl, [edi+eax]				;j = j + S[i]
		and bl, 255						;j = (j + S[i]) & 255

		pusha
		call swap						;swap S[i],S[j]
		popa							
		
		mov ax, i						;ax=i
		mov bx, j						;bx=j

		mov al, [edi + eax]				;al = S[i]
		mov bl, [edi + ebx]				;bl = S[j]	
		add ax,bx						;ax = S[i] + S[j]	
		and ax,255						;ax = (S[i] + S[j]) & 255
		mov al, [edi+eax]				;al = S[(S[i] + S[j])&255]	

		lea esi, plaintext				;load base address of plaintext in esi
		xor bx,bx						; bx = 0
		mov bl, [esi + edx]				;bl = plaintext[n]	
		xor ax,	bx						;S[(S[i] + S[j]) & 255] ^ plaintext[n]
		lea esi, ciphertext				;load base address of ciphertext in esi
		mov [esi + edx],al				;ciphertext[n] = S[(S[i] + S[j]) & 255] ^ plaintext[n]
		inc dx							;n++
		cmp dx,cx						;check if n-len=0 if so we will not jump to L_Out and this loop exit
		jnz L_Out
		ret

RC4_Output ENDP

;----------------------------------------------------------------------------;
; Part of ROT13. might be used in multiple places in the code
; input base address is given in ESI register e.g.-> lea esi, [S] before calling
; strlen function, return length in EAX reg -in hex- 
; while(S[ecx] != '\0') ecx++; 



strlen proc
	   xor ecx, ecx		   	   ;strlen = 0
	   ;lea esi, [S]		   ;move base addr of S to esi -> **this line moved to the caller function
	   jmp L2
    L5:
	   add ecx,1			   ; cx++
    L2: 
	   mov edx, [esi + ecx]		   ; edx = s[ecx]
	   test edx, edx		   ; testing if edx is zero, zf is set -> done b using bitwise AND 
	   jne L5			   ; zf not set, string is not ended 
	   mov eax, ecx
	   ret 
;-----------------------------------------------------------------------------;

strlen endp
end main
