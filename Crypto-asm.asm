



.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:dword

.data 
S				DB		256 dup(?)				; Declaring uninitialized 256 char
key				DB		"Secret",0
plaintext		DB		"dola",0						;		256 dup(?)
ciphertext		DB		256 dup(?)
key_Length		DB		?
plain_Length	DB		?
i				DW		?
j				DW		?
N				DW		256
ROT13_str_len			DW	        0

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

	Init_L1:
		mov [edi],al			;Storing the value of i to the ith element in the array
		add edi, TYPE S			;TYPE (Return the size of a single element in the array) so we move to the next element in the array
		inc al					;increment counter
		loop Init_L1			;jump to the loop untill we make 256 iterations to break


		COMMENT ^
		for (i = j = 0; i < 256; i++) {
			j = (j + key[i % key_length] + S[i]) & 255;
		    swap(S, i, j);
		}
		^
		mov edi, OFFSET S		;Storing the start address of array S in the index register EDI
		mov esi, OFFSET key		;Storing the start address of array key in the index register ESI
		mov eax, 0
		mov ebx, 0
		mov i,0
		mov j,0
		mov cx, LENGTHOF S		;initialize ecx with the number of elements  in the array
		xor edx,edx
	
	Init_L2:
		mov ax,  i				;move the value of i to AX to be divided with key length and the value of the remainder will be stored in AH so shift right it with 8
		
		pusha
		mov esi, OFFSET key
		call strlen				;calculate the length of key
		mov key_Length,al
		popa
		
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
		jnz Init_L2				;check if zero flag isn't set to jump to L2,if set it will continue to the next instruction
		
		COMMENT ^
			i = j = 0;
		^
		mov ax,ax
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
		lea edi, S						;store address of array S in edi
		lea esi, plaintext				;load base address of plaintext in esi
		xor eax,eax
		xor ebx,ebx
		
		pusha
		lea esi, plaintext				;load base address of plaintext in esi
		call strlen
		mov plain_Length,al
		popa
		
		xor edx, edx					;n (counter)
	L_Out:
		mov ax, i						;ax = i
		mov bx, j						;bx = j

		
		inc ax							;i = i + 1
		push dx
		div N							;remainder stored in dx
		mov i, dx						;i = (i + 1) % 256	
		pop dx
		
		mov ax, i						;ax=i
		mov al, [edi+eax]				;ax = S[i]
		
		add bx, ax						;j = j + S[i]
		mov ax,bx						;move j to ax to divide j/256
		push dx
		div N							;remainder stored in dx
		mov j, dx						;store the remainder in j
		pop dx

		pusha
		call swap						;swap S[i],S[j]
		popa							
		
		mov ax, i						;ax=i
		mov bx, j						;bx=j

		mov al, [edi + eax]				;al = S[i]
		mov bl, [edi + ebx]				;bl = S[j]	
		add ax,bx						;ax = S[i] + S[j]	
		
		push dx
		div N
		mov ax, dx						;;ax = (S[i] + S[j]) % 256	
		pop dx
		
		mov al, [edi+eax]				;al = S[(S[i] + S[j])%256]	

		xor bx,bx						; bx = 0
		lea esi, plaintext				;load base address of plaintext in esi
		mov bl, [esi + edx]				;bl = plaintext[n]	
		xor ax,	bx						;S[(S[i] + S[j]) % 256] ^ plaintext[n]
		lea esi, ciphertext				;load base address of ciphertext in esi
		mov [esi + edx],al				;ciphertext[n] = S[(S[i] + S[j]) & 255] ^ plaintext[n]
		inc dx							;n++
		
		cmp dl,plain_Length				;check if n-len=0 if so we will not jump to L_Out and this loop exit
		
		jnz L_Out
		ret

RC4_Output ENDP

;----------------------------------------------------------------------------;
; Input text base addrress is taken in ESI register 
; Output is in EAX -> base addrress of the input
ROT13 proc
    push ebp				  
    mov ebp, esp
    xor ecx,ecx			  ; loop counter -> i=0
    call strlen			  ;eax contains the lengthb of the text
    mov [ROT13_str_len], eax		  ; len = strlen(text)
    jmp Loop_cond

    Loop_main:
	   movzx edx, BYTE PTR[esi + ecx]	    ;n = text[i]
	   ; if(n>=65 && n<=90)
	   cmp edx, 65
	   jl else_if
	   cmp edx, 90 
	   jg else_if 
	   ; inner if
	   ; if(n>=65 && n<=77)
	   cmp edx, 65
	   jl sub_13
	   cmp edx, 77
	   jg sub_13

	   ; add 13 to the char 
	   add edx, 13
	   mov BYTE PTR[esi + ecx], dl			
	   
	   jmp Loop_inc

    sub_13:
	   sub edx,13
	   mov BYTE PTR[esi + ecx], dl
	   jmp Loop_inc

    else_if:
	   ; if(n>=97 && n<=122)
	   cmp edx, 97
	   jl Loop_inc
	   cmp edx, 122 
	   jg Loop_inc
	   ; inner if
	   ; if(n>=97 && n<=109)
	   cmp edx, 97
	   jl sub_13
	   cmp edx, 109
	   jg sub_13

	   ; add 13 to the char 
	   add edx, 13
	   mov BYTE PTR[esi + ecx], dl			
	   
	   jmp Loop_inc

    Loop_inc:
	   add ecx,1 
    Loop_cond:
	   cmp ecx, [ROT13_str_len]
	   jle Loop_main

    mov eax, esi
    mov esp,ebp			  ; Reset the stack pointer
    pop ebp				  ; Restore the old frame pointer
ROT13 endp

;----------------------------------------------------------------------------;


;----------------------------------------------------------------------------;
; Part of ROT13. might be used in multiple places in the code
; input base address is given in ESI register e.g.-> lea esi, [S] before calling
; strlen function, return length in EAX reg -in hex- 
; while(S[ecx] != '\0') ecx++; 



strlen proc
	   xor ecx, ecx		   	   ;strlen = 0
	   ;lea esi, [S]		   ;move base addr of S to esi -> **this line moved to the caller function
	   jmp STRLEN_L2
    STRLEN_L1:
	   add ecx,1			   ; cx++
    STRLEN_L2: 
	   movzx edx, BYTE PTR[esi + ecx]		   ; edx = s[ecx]
	   test edx, edx		   ; testing if edx is zero, zf is set -> done b using bitwise AND 
	   jne STRLEN_L1			   ; zf not set, string is not ended 
	   mov eax, ecx
	   ret 
;-----------------------------------------------------------------------------;

strlen endp
end main
