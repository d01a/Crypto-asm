INCLUDE Irvine32.inc
INCLUDE Macros.inc

.386

.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:dword

.data 
S				DB		256 dup(?)				; Declaring uninitialized 256 char
key				DB		256 dup(?)	; 
plaintext		        DB			256 dup(?) ; 					
ciphertext		        DB		256 dup(?)
key_Length		        DB		?
plain_Length	                DB		?
i				DW		?
j				DW		?
N				DW		256
ROT13_str_len			DD	        0
input			        DB			256 dup(?) ; 
size64			        DD		?
output			        DB		256 dup(?)
b64chars		        DB		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",0
len				dd		?
b3				dd		?
fvalid                          DD              ?
b64invs1     	DW      62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58,59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4
b64invs2    	DW       5,6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1
b64invs3        DW      26,27, 28,29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,43, 44, 45, 46, 47, 48, 49, 50, 51
ret_of_decode   dd      ?
out_len         dd      ?

; choice variable  
intNum    DWORD ?
promptBad BYTE "Invalid input, please enter again",13,10,0

;welcome message
;welcomemsg byte  "*****************************************************   Crypto-ASM  ****************************************************",13,10,0
welcomemsg byte  48 DUP ("*") , "  Welcome to Crypto-ASM  " , 47 DUP("*"),13,10,0
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

;output choice
intChoc DWORD ?

;key and plaintext ip
ipstr byte " Please Enter The String You Wanna Encrypt....",13,10,0
ipkey byte "Please Enter The Key....",13,10,0


;base64 ipmsg ; choice msg 
base64msg byte "Do you Wanna Encode or Decode ? ",13,10,0
ende_msg byte "Enter 0 to Encode , 1 to Decode .... ",13,10,0

;base64 choice var
endeVar DWORD ?


;outputmsg
opmsg byte "Here's you CipherText ....",13,10,0


; current colum , row
x db ? ;colums
y db ? ;rows



 ; Code Section 
.code 
main PROC
;printing welcome message
	welcome:	

			   lea edx , welcomemsg 
			   call WriteString
			  
	;printing out the menu
	menu:
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
read:  call ReadInt  ; if OF=0 , that means that it's a good input and eax conatins a valid binary value , sf=sign 
       jno  goodInput

       mov  edx,OFFSET promptBad ; if it got here , that means that OF =1 and eax =0 ;(invalid input)
       call WriteString
       jmp  read        ;go input again

goodInput:
       mov  intNum,eax  ;store good value

; comparing input to menu
		cmp intNum , 1 ; if input is 1 , call rc4 functions 
		jne elseifbranch
		ifbranch:           ; if input is 1  then go to rc4 function 

			; getting key and text from the user
		
			lea edx , ipstr
			mWriteLn " "
			call WriteString
			mWriteLn " "
			lea edx , plaintext ;
			mov ecx ,255 ;buffer size - 1 (space for null char )
			call ReadString
			lea edx , ipkey
			mWriteLn " "
			call WriteString
			mWriteLn " "
			lea edx , key
			mov  ecx,255            ;buffer size - 1
			call ReadString
		
		   ; calling procedures after talking 

			call RC4_INIT 
			call RC4_OUTPUT
			mWriteLn " "
			mWriteLn "Enter 0 to Show it in HEXA or 1 to Show it in ASCII"
			mWriteLn " "


			; reading input		
readopchoc: call ReadInt
			jno  rightChoc
badchoc:	mWriteLn " "
			mov  edx,OFFSET promptBad
			call WriteString
			mWriteLn " "
			jmp  readopchoc        ;go input again

rightChoc:
	   mov  intChoc,eax  ;store good value


	   ; checking user choice ;( if 0 display in hexa )
		cmp intChoc , 0
		jne ifascii  ; (if not 0 -"means 1 in this case"- go to ifascii cond. )
	ifhexa:
	 ; Formmating Output
		   mWriteLn " "
		   lea edx , opmsg
		   call WriteString
		   mWriteLn " "
		   mWriteLn "***************************************"
		   mWriteLn " "
			mov esi ,0
	print_ciphertexthexa:  ;(printing out the hexa values directly from memory using WriteHexB)
			cmp [ciphertext+esi],00 ; comparing if the value there is 00 ;(means that we finished)
			je done
			movzx eax , [ciphertext + esi]  ; using movzx because operands aren't from the same size
			mov  ebx,TYPE [ciphertext + esi]
			call WriteHexB  ; writing the byte in order to stdout
			inc esi ; incrementing index
			jmp print_ciphertexthexa


	  ifascii:
			cmp intChoc ,1  ; checking user choice  as if it's 1 , go to printing ascii cond ., if not , prompt badchoice
			jne badchoc
			 ; Formmating Output
			   mWriteLn " "
			   lea edx , opmsg
			   call WriteString
			   mWriteLn " "
			   mWriteLn "***************************************"
			   mWriteLn " "
			lea edx , ciphertext ; printing out the ciphertext
			mWriteLn " "
			call WriteString
			mWriteLn " "


done:	  ; some formmating and after finishing it jumps to ("another" label)  to ask the user if another alg. is needed
			mWriteLn " "
			mWriteLn " "
		   mWriteLn"***************************************"
		   mWriteLn " "
				jmp another


;;;;;;;;;;;;;;;;;;;;;;;;

		elseifbranch:       ; if input is 2 then go to rot13 function
			cmp intNum , 2
			jne elseifbranch2
			lea edx , ipstr  ; loading the variable address into edx to take input using WriteString Proc.
			mWriteLn " "
			call WriteString
			mWriteLn " "
			lea edx , plaintext ; same as ipstr
			mov ecx ,255 ;buffer size - 1 (space for null char )
			call ReadString
			mWriteLn " "
			lea edx , opmsg ; same as above , but here to print out output message to display the ciphertext
			call WriteString
			; some formmating
			mWriteLn " "
		   mWriteLn "***************************************"
			 mWriteLn " "
			mov ecx, 0;
		; just passin the base address of the string  to be encrypted 
			lea esi , plaintext
			call ROT13
			mov edx, eax  ; getting the address of the encrypted string to be printed out
			call WriteString

		  mWriteLn " "
		  mWriteLn " "
		   mWriteLn "***************************************"
		   mWriteLn " "
			jmp another

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		elseifbranch2: ; if input is 3 , then go to base64 function
			cmp intNum ,3
			jne elseifbranch3
			lea edx , base64msg  ; loading the variable address into edx to take input using WriteString Proc.
			mWriteLn " "
			call WriteString
			mWriteLn " "
			lea edx , ende_msg  ; loading the variable address into edx to take input using WriteString Proc.
			mWriteLn " "
			call WriteString
			mWriteLn " "
						; reading input		
						endeChoc: call ReadInt
									jno  endeGoodChoc
						endeBadchoc:	mWriteLn " "
									mov  edx,OFFSET promptBad
									call WriteString
									mWriteLn " "
									jmp  endeChoc        ;go input again

						endeGoodChoc:
								mov  endeVar,eax  ;store good value


	   ; checking user choice ;( if 0 , call Encode Function )
			cmp endeVar , 0
			jne decode  ; (if not 0 -"means 1 in this case"- go to Decode Function )
			mWriteLn " "
			mWriteLn " "		
			mWriteLn "Enter the Text You Wanna Encode.... "
			mWriteLn " "
			lea edx , input ; putting the input buffer address into edx to call Read String
			mov ecx ,255 ;buffer size - 1 (space for null char ) 
			call ReadString
			call base64
			jmp  b64done

		  decode:
			cmp endeVar ,1  ; checking user choice  as if it's 1 , go to printing ascii cond ., if not , prompt badchoice
			jne endeBadchoc ; if the user entered a value other than 0,1  just go and prompt "Bad Prompt" and ask again for the input
			mWriteLn " "
			mWriteLn "Enter the Text You Wanna Decode.... "
			mWriteLn " "
			lea edx , input ; same as base64msg
			mov ecx ,255 ;buffer size - 1 (space for null char )
			call ReadString
			call  b64_decode



     
b64done:   ; some formmating and after finishing it jumps to ("another" label)  to ask the user if another alg. is needed
					 ; Formmating Output
					
					
					mWriteLn " "
 					mWriteLn " "
					lea edx , opmsg
					call WriteString
					mWriteLn " "
					mWriteLn "***************************************"
					mWriteLn " "
					lea edx , output
					call WriteString
					mWriteLn " "
					mWriteLn " "
				   mWriteLn"***************************************"
				   mWriteLn " "
		   		jmp another
		
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

ROT13 proc
    push ebp				  
    mov ebp, esp
    xor ecx,ecx			  ; loop counter -> i=0
	;esi must contain Base address of the text
    call strlen			  ;eax contains the lengthb of the text
    mov [ROT13_str_len], eax		  ; len = strlen(text)
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
	   cmp ecx, [ROT13_str_len]
	   jle Loop_main

	; return the base address of the text
    mov eax, esi
    mov esp,ebp			  ; Reset the stack pointer
    pop ebp				  ; Restore the old frame pointer
    ret
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
	 b64_decode  PROC
        lea esi, [input]
		call strlen             ;len = strlen(input)
		mov len,eax
		cmp len,0
		je ret0
		lea esi, [output]
        call strlen 
        mov out_len ,eax
        cmp out_len,0          	
        je ret0     	  
        call b64_decoded_size 
		mov ebx,size64
		cmp out_len,ebx
	    jg ret0
		mov eax,len
		mov ebx,4
		div ebx
		cmp edx,0
		jne ret0
	    mov i,0 
		mov ecx,len
	decode_l1:
         call b64_isvalidchar
		 inc i
		 cmp fvalid,0
		 je ret0
		 loop decode_l1
                 mov i,0
	         mov j,0
	        mov ebx,0
	        mov bl,input
	        decode_l2:
               mov edx,0
	      mov dx,[ebx+i]
	       sub edx,43
    b64in:
	     cmp edx,27
	     jl value1
	     cmp edx,54
	     jl value2
	     jg value3
	
	value1:
	    mov ecx,0
	    mov cx,b64invs1
	    mov eax,[ecx+edx]       
            jmp aft_v	
	value2:
	   mov ecx,0
	   sub edx,27
	   mov cx,b64invs2
       mov eax,[ecx+edx]
	   jmp aft_v
	value3:
	   mov ecx,0
	   sub edx,54
	   mov cx,b64invs3
           mov eax,[ecx+edx]
	aft_v:    
	
	
	ret0:
	    mov ret_of_decode,0
		ret
		
 

b64_decode  endp
end main
