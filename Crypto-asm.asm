INCLUDE Irvine32.inc
INCLUDE Macros.inc

.386

.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:dword

.data 
S				DB		256 dup(?)				; Declaring uninitialized 256 char
key				DB		"Secret",0
plaintext		        DB		"dola",0						;		256 dup(?)
ciphertext		        DB		256 dup(?)
key_Length		        DB		?
plain_Length	                DB		?
i				DW		?
j				DW		?
N				DW		256
ROT13_str_len			DW	        0
input			        DB		"Hello World!",0
size64			        DD		?
output			        DB		256 dup(?)
b64chars		        DB		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",0
len				dd		?
b3				dd		?
fvalid                          DD              ?

intNum    DWORD ?
promptBad BYTE "Invalid input, please enter again",13,10,0

;welcome message
welcomemsg byte  "*****************************************************   Crypto-ASM  ****************************************************",13,10,0
;welcomemsg byte "Welcome To Crypto-ASM ",13,10,0
;menu choices
choiceQues byte "Choose the algorithm",13,10,0	

rc4c byte "1. RC4",13,10,0

rot13c byte "2. ROT13",13,10,0

base64c byte "3. BASE64",13,10,0

exitc byte "Press 4 To Exit",13,10,0

;error msg

errormsg byte "Wrong input try again...",13,10,0

; message to print out  if user wanted another algo.
anothermsg byte "Wanna try another algorithm... ?",13,10,0

; current colum , row
x db ? ;colums
y db ? ;rows
  
.code 
main PROC
;printing welcome message
	welcome:	
	COMMENT ^
			  call GetMaxXY
			  dec  dl         ;highest column number = X-1
			  movzx eax,dl
			  mov edx, 2h
			  div dl
			  mov x , al
			 ^ 
			  ; centering welcome message by changing cursor location
			   mGotoxy 0,0
			   lea edx , welcomemsg
			   call WriteString
			  
	;printing out the menu
	menu:
				mGotoxy 0,2
				mov edx,OFFSET choiceQues
				call WriteString
				mWriteLn " "
	 again:	   mov edx,OFFSET rc4c
				call WriteString
				mWriteLn " "
				mov edx,OFFSET rot13c
				call WriteString
				mWriteLn " "
				lea edx , base64c
				call WriteString
				mWriteLn " "
				lea edx , exitc
				call WriteString
				mWriteLn " "
; reading input		
read:  call ReadInt
       jno  goodInput

       mov  edx,OFFSET promptBad
       call WriteString
       jmp  read        ;go input again

goodInput:
       mov  intNum,eax  ;store good value

; comparing input to menu
		cmp intNum , 1
		jne elseifbranch
		ifbranch:           ; if input is 1  then go to rc4 function 
		; to be edited
		COMMENT ^   
		   lea edx , S
			mov ecx , BUFFERSIZE
			call ReadString
			lea edx , key
			lea esi, key
			call strlen				;calculate the length of key
			mov key_Length,al
			movzx ecx ,key_Length
			call RC4_INIT
			call RC4_Output
			lea edx , ciphertext
			mWriteLn " "
			call WriteString
	^	
			call RC4_INIT
			call RC4_OUTPUT
			pop ax
			lea edx , ciphertext
			call WriteString
			jmp another
		elseifbranch:       ; if input is 2 then go to rot13 function
			cmp intNum , 2
			jne elseifbranch2
			jmp another
		elseifbranch2: ; if input is 3 , then go to base64
			cmp intNum ,3
			jne elseifbranch3
			jmp finish
		elseifbranch3: ; if input is 4 , then exit
			cmp intNum , 4
			jne elseifbranch4
			jmp finish
		elseifbranch4:      ; if input is anything else   show error message and display again
			lea edx, errormsg
			call WriteString
			jmp read
another:  ; if the user wants to try another algorithm
	lea edx , anothermsg
	call WriteString
	jmp again

finish:
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
	;esi must contain Base address of the text
    call strlen			  ;eax contains the lengthb of the text
    ;mov [ROT13_str_len], eax		  ; len = strlen(text)
    xor ecx,ecx			  ; loop counter -> i=0
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
	   ;cmp ecx, [ROT13_str_len]
	   jle Loop_main
	; return the base address of the text
    mov eax, esi

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

;-----------------------------------------------------------------------------;

base64 proc
		pusha

		call to64Size
		mov eax,size64				
		mov [output + eax] ,0		
		lea esi, input

		call strlen
		mov ecx ,eax
		mov len, ecx

		mov ebx,0h		
		mov eax,0h		
	l1:
		cmp eax, len
		jge l3
		mov dl,[input +eax]
		inc eax
		cmp eax, len
		jge shiftl1
		shl edx,8
		mov dl, [input +eax]
		jmp noshiftl1
	shiftl1:
		shl edx ,8
	noshiftl1:
		inc eax
		cmp eax, len
		jge shiftl2
		shl edx,8
		mov dl,[input +eax]
		jmp noShiftl2
	shiftl2:
		shl edx ,8
	noShiftl2:
		mov b3,edx
		shr edx,18
		and edx,3fh
		mov cl ,[b64chars + edx ]
		mov [output + ebx],cl
		inc ebx
		mov edx, b3
		shr edx,12
		and edx,3fh
		mov cl ,[b64chars + edx ]
		mov [output + ebx],cl
		inc ebx
		sub eax,1
		cmp eax,len
		jge equalSign1
		mov edx, b3
		shr edx, 6
		and edx, 3fh
		mov cl ,[b64chars + edx ]
		mov [output + ebx],cl
		jmp endEqualSign1
	equalSign1:
		mov [output + ebx], '='
	endEqualSign1:
		inc ebx
		inc eax
		cmp eax,len
		jge equalSign2
		mov edx, b3
		and edx, 3fh
		mov cl ,[b64chars + edx]
		mov [output + ebx],cl
		jmp endEqualSign2
	equalSign2:
		mov [output + ebx], '='
	endEqualSign2:
		inc eax
		inc ebx
		jmp l1
	l3:
		popa
base64 endp


to64Size proc
		pusha
		mov eax ,LENGTHOF input
		sub eax, 1
		mov ebx, 3
		xor edx, edx  
		div ebx
		cmp edx, 0
		jne inc3
		mov ebx,4
		mul ebx
		jmp sizeEnd
	inc3:
		mov eax ,LENGTHOF input
		sub eax, 1
		add eax ,3
		sub eax, edx
		xor edx, edx 
		mov ebx,3
		div ebx
		mov ebx,4
		mul ebx
	sizeEnd:
		mov size64,eax
		popa
to64Size endp
b64_decoded_size PROC
                lea esi, [input]
		call strlen
		
		;len = strlen(input)
		
		mov ecx ,eax
		mov len, ecx
		mov eax, len
		
		;ret = len / 4 * 3

		mov ebx,4
		div ebx
		mov ebx,3
		mul ebx
        
		;if (in == NULL)

		cmp len,0
		je r1

	    ;for loop to find ret without "="

		mov ecx,len
		mov edx,'='
	dsize_l1:
	        dec ecx
	    
		;if(input[i]== '=')

		cmp [ecx+input],dl
		
		;go to ret-- if z flag which mean it equal '='

		jz dec_ret
	
	    ;else break	

		jnz r1
		
		loop dsize_l1
       dec_ret:
	  
	       ;ret--

	       dec eax
	       jmp dsize_l1
	r1:
              mov size64,eax 
	      ret     
b64_decoded_size endp

b64_isvalidchar PROC
           pusha
	   mov ecx,0
	   mov edx, 0
	   mov cx,i
	   mov dl,[input+ecx]
	   cmp edx, '0'
	   jl con2
	   cmp edx, '9' 
	   jg con2
	   
	   jmp ret_b64_isvalidchar
     con2:  
	   cmp edx, 'A'
	   jl con3
	   cmp edx, 'Z'
	   jg con3

	   jmp ret_b64_isvalidchar
	   con3:
           cmp edx, 'a'
	   jl con4
	   cmp edx, 'z'
	   jg con4


	   jmp ret_b64_isvalidchar
	   con4:
	   cmp edx,'='
	   je ret_b64_isvalidchar 
           cmp edx,'+'
	   je ret_b64_isvalidchar
	   cmp edx,'/'
	   je ret_b64_isvalidchar
	   
	else_b64_isvalidchar:
	   mov fvalid,0
	   popa
	   ret

	ret_b64_isvalidchar:
	   mov fvalid,1
	   popa
	   ret
    b64_isvalidchar endp
end main
