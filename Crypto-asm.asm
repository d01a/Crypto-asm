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
out_len                         dd	        ?
b3				dd		?
b64invs1     	Db      62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58,59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4
b64invs2    	Db       5,6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1
b64invs3        Db      26,27, 28,29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,43, 44, 45, 46, 47, 48, 49, 50, 51
fvalid          DD      ?
ret_of_decode      dd      ? 
ret_of_b64in     dd        ?
v                dd        ?
i_dec            dw       ?
j_dec            dw        ?
; choice variable  
intNum    DWORD ?
promptBad BYTE "Invalid input, please enter again",13,10,0
;again var
flag byte 0
flag1 byte 0

; again 
againVar DWORD ?

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
ipkey1 byte "Please Enter The New Key....",13,10,0

;base64 ipmsg ; choice msg 
base64msg byte "Do you Wanna Encode or Decode ? ",13,10,0
ende_msg byte "Enter 1 to Encode , 2 to Decode .... ",13,10,0

;base64 outputmsg
notValidMsg byte "The Input Cannot be Decoded ",10,13,10,13,"! NOT VALID !",10,13,0
base64openmsg byte "Here's Your Encoded Text",13,10,0
base64opdemsg byte "Here's Your Decoded Text",13,10,0
;base64 choice var
endeVar DWORD ?


;outputmsg
opmsg byte "Here's Your CipherText ....",13,10,0


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
				jmp inread
noinread: mWriteLn "Wrong Input Try Again..."
 ; getting user input in intNum variable
inread:		mov ebx, OFFSET intNum
		call reading

; comparing input to menu
		cmp intNum , 1 ; if input is 1 , call rc4 functions 
		jne elseifbranch
		ifbranch:           ; if input is 1  then go to rc4 function 

			; getting key and text from the user
			cmp flag ,1 
			jne normalrc4		
			mWriteLn "Enter 1 To Use The old output again , or 2 to Use New Input..."
			jmp newrc4
			
		
notoldrc4:	mWriteLn "Wrong Input Try Again .... "
newrc4:		mov ebx , OFFSET againVar
			call reading

			cmp againVar ,2
			jne mvopiprc4
normalrc4:	lea edx , ipstr
			mWriteLn " "
			call WriteString
			mWriteLn " "
			lea edx , plaintext ;
			mov ecx ,255 ;buffer size - 1 (space for null char )
			call ReadString
			lea edx , ipkey
			jmp nomvrc4
mvopiprc4:	
			cmp againVar , 1
			jne	notoldrc4

			; op should be moved to ip here
			mov eax, OFFSET ciphertext
			mov ebx , OFFSET plaintext
			call copystr
				lea edx , ipkey1




nomvrc4:		mWriteLn " "
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
			jmp hexorasc

nohexorasc: 	mWriteLn "Wrong Input Try Again .... "
hexorasc:	mov ebx, OFFSET intChoc
			call reading


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
			jne nohexorasc
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


done:	  
			mov eax, OFFSET ciphertext
			mov ebx , OFFSET plaintext
			call copystr
			mov flag,1
			; some formmating and after finishing it jumps to ("another" label)  to ask the user if another alg. is needed
			mWriteLn " "
			mWriteLn " "
		   mWriteLn"***************************************"
		   mWriteLn " "
				jmp another


;;;;;;;;;;;;;;;;;;;;;;;;

		elseifbranch:       ; if input is 2 then go to rot13 function
			cmp intNum , 2
			jne elseifbranch2
			cmp flag ,1
			jne normalrot13
			mWriteLn "Enter 1 To Use The old output again , or 2 to Use New Input..."
			jmp newrot13
notoldrot13:	
			mWriteLn "Wrong Input Try Again .... "
newrot13:		
			mov ebx , OFFSET againVar
			call reading
			cmp againVar,2
			jne mvopiprot13

normalrot13:
			lea edx , ipstr  ; loading the variable address into edx to take input using WriteString Proc.
			mWriteLn " "
			call WriteString
			mWriteLn " "
			lea edx , plaintext ; same as ipstr
			mov ecx ,255 ;buffer size - 1 (space for null char )
			call ReadString
mvopiprot13:mWriteLn " "
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
			mov edx, DWORD PTR[ciphertext] ; getting the address of the encrypted string to be printed out
			call WriteString
		  mWriteLn " "
		  mWriteLn " "
		   mWriteLn "***************************************"
		   mWriteLn " "


		   ; op should be moved to ip here
			; no input should be moved here because rot13 encrypts the input inplace
			
			mov flag,1 ; to mark valid operation happened

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
			call enorde
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; this part is to make the user able to use the old output or enter a new one ; this for encoding part
oldbaseen64:	mWriteLn "Enter 1 To Use The old output again , or 2 to Use New Input..." ; 
			jmp newbaseen64
notoldbaseen64:	
			mWriteLn "Wrong Input Try Again .... "
newbaseen64:		
			mov ebx , OFFSET againVar
			call reading
			cmp againVar,1
			jne newenbase64
			jmp nonewenip

;;;;;;;;;;;;
;			; this part is to make the user able to use the old output or enter a new one ; this for decoding part
oldbasede64:	mWriteLn "Enter 1 To Use The old output again , or 2 to Use New Input..."
				jmp newbasede64

notoldbasede64:	
			mWriteLn "Wrong Input Try Again .... "
newbasede64:		
			mov ebx , OFFSET againVar
			call reading
			cmp againVar,1
			jne newdebase64
			
			jmp nonewdeip

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this to make the user choose if he wants to encode or decode....


noenorde: mWriteLn "Wrong Input Try Again .... "
						; reading input		
enorde:					mov ebx , OFFSET endeVar
						call reading
;;;;;;;;;;;;;;;
	   ; checking user choice ;( if 0 , call Encode Function )
			lea edx,endeVar
			cmp endeVar , 1
			jne decode  ; (if not 0 -"means 1 in this case"- go to Decode Function )
			cmp flag ,1 
			je oldbaseen64
			jmp normen
newenbase64: cmp againVar ,2
			jne notoldbaseen64
normen:		mWriteLn " "
			mWriteLn " "		
			mWriteLn "Enter the Text You Wanna Encode.... "
			mWriteLn " "
			lea edx , plaintext ; putting the input buffer address into edx to call Read String
			mov ecx ,255 ;buffer size - 1 (space for null char ) 
			call ReadString
nonewenip:	call base64
			mWriteln " "
			mWriteln " "
			lea edx, base64openmsg ; write encode op msg then jump to done part to print the text
			call WriteString
			jmp  b64endone

		  decode:
			cmp endeVar ,2  ; checking user choice  as if it's 1 , go to printing ascii cond ., if not , prompt badchoice
			jne noenorde ; if the user entered a value other than 0,1  just go and prompt "Bad Prompt" and ask again for the input
			cmp flag ,1 
			je oldbasede64
			jmp normde
newdebase64: cmp againVar ,2
			jne notoldbasede64
normde:		mWriteLn " "
			mWriteLn "Enter the Text You Wanna Decode.... "
			mWriteLn " "
			lea edx , plaintext ; same as base64msg
			mov ecx ,255 ;buffer size - 1 (space for null char )
			call ReadString

nonewdeip:	call  b64_decode
			cmp ret_of_decode , 1
			jne notValidDe

     
b64done:   ; some formmating and after finishing it jumps to ("another" label)  to ask the user if another alg. is needed
					 ; Formmating Output
					
			
					mWriteLn " "
 					mWriteLn " "
					lea edx , base64opdemsg
					call WriteString
b64endone:			mWriteLn " "
					mWrite "***************************************"
					mWriteLn " "
					mWriteLn " "
					lea edx , ciphertext
					call WriteString
					mWriteLn " "
					mWriteLn " "
				   mWrite"***************************************"
				   mWriteLn " "
	
				   mWriteLn " "
					
	; op should be moved to ip here ;(to enable ip redirection)
					mov eax, OFFSET ciphertext
					mov ebx , OFFSET plaintext
					call copystr


				   mov flag,1 ; to mark that there was a valid operation 
	   			   jmp another
notValidDe:
				mWriteLn " "
 				mWriteLn " "
				lea edx , notValidMsg
				call WriteString
				mWriteLn " "
 				mWriteLn " "
				jmp oldbasede64
		
		elseifbranch3: ; if input is 4 , then exit
			cmp intNum , 4
			jne elseifbranch4
			jmp finish
		elseifbranch4:      ; if input is anything else   show error message and display again
			jmp noinread
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
    mov DWORD PTR [ciphertext], esi
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
		mov [ciphertext + eax] ,0		
		lea esi, plaintext

		call strlen
		mov ecx ,eax
		mov len, ecx

		mov ebx,0h		
		mov eax,0h		
	l1:
		cmp eax, len
		jge l3
		mov dl,[plaintext +eax]
		inc eax
		cmp eax, len
		jge shiftl1
		shl edx,8
		mov dl, [plaintext +eax]
		jmp noshiftl1
	shiftl1:
		shl edx ,8
	noshiftl1:
		inc eax
		cmp eax, len
		jge shiftl2
		shl edx,8
		mov dl,[plaintext +eax]
		jmp noShiftl2
	shiftl2:
		shl edx ,8
	noShiftl2:
		mov b3,edx
		shr edx,18
		and edx,3fh
		mov cl ,[b64chars + edx ]
		mov [ciphertext + ebx],cl
		inc ebx
		mov edx, b3
		shr edx,12
		and edx,3fh
		mov cl ,[b64chars + edx ]
		mov [ciphertext + ebx],cl
		inc ebx
		sub eax,1
		cmp eax,len
		jge equalSign1
		mov edx, b3
		shr edx, 6
		and edx, 3fh
		mov cl ,[b64chars + edx ]
		mov [ciphertext + ebx],cl
		jmp endEqualSign1
	equalSign1:
		mov [ciphertext + ebx], '='
	endEqualSign1:
		inc ebx
		inc eax
		cmp eax,len
		jge equalSign2
		mov edx, b3
		and edx, 3fh
		mov cl ,[b64chars + edx]
		mov [ciphertext + ebx],cl
		jmp endEqualSign2
	equalSign2:
		mov [ciphertext + ebx], '='
	endEqualSign2:
		inc eax
		inc ebx
		jmp l1
	l3:
		popa
base64 endp


to64Size proc
		pusha
		mov eax ,LENGTHOF plaintext
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
		mov eax ,LENGTHOF plaintext
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
                lea esi, [plaintext]
		call strlen
		
		;len = strlen(plaintext)
		
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
	    
		;if(plaintext[i]== '=')

		cmp [ecx+plaintext],dl
		
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
	   mov dl,[plaintext+ecx]
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
    push ebp				  
    mov ebp, esp
		mov ciphertext ,0
        lea esi, [plaintext]
		call strlen             ;len = strlen(plaintext)
		mov len,eax
		cmp len,0
		je ret0
		
		; to put "/0" at the end of ciphertext

		call b64_decoded_size
		mov ebx,size64
		mov [ciphertext+ebx],0

        ;lea esi, [ciphertext]
        ;call strlen 
        ;mov out_len ,eax
        ;cmp out_len,0          	
        ;je ret0     	  
        ;call b64_decoded_size 
		; mov ebx,size64
		; cmp out_len,ebx
	    ; jg ret0
		
		;check that the len of input is Multiples of 4 
		; if true return 0
		mov eax,len
		mov ebx,4
		mov edx,0
		div ebx
		cmp edx,0
		jne ret0
	    mov i,0 
		mov ecx,len
	decode_l1:
         ;to check the validation of every char 
          ; if not vaild return 0
		
		call b64_isvalidchar
		 inc i
		 cmp fvalid,0
		 je ret0
		 loop decode_l1
         mov i_dec,0
	      mov j_dec,0
	
	;;;;;;;;;;;;;;start decoding;;;;;;;;;;;;;;;;;;;
	;;first is to merge the three values in "v"
	;;make a 4*6==24bit then it will give 3 values 3*8 of 8 bit 
	decode_l2:
	    
		;v= b64invs[in[i]-43]

		mov ebx,0
		lea ebx,[plaintext]    
        mov edx,0
	    mov esi,0
	    mov si,i_dec
	    mov dl,[ebx+esi]       ;dl=in[i]
		sub dl,43
        call b64in    
	    
		;;;;;;;v = (v << 6) | b64invs[in[i+1]-43];;;;;;;;
		shl eax,6       ;;;(v << 6)    
	    push eax
	    mov edx,0
		mov esi,0
		mov si,i_dec
		mov dl,[ebx+esi+1]    ;dl=in[i+1]
		sub edx,43
		call b64in
		mov ret_of_b64in,eax
		pop eax
		or eax,ret_of_b64in
        
	;;;;;;v = in[i+2]=='=' ? v << 6 : (v << 6) | b64invs[in[i+2]-43];;;;;;;;;;;;;;;;;
		mov edx,0
		mov esi,0
		mov si,i_dec
		mov dl,[ebx+esi+2]
		cmp edx,'='
		jne con1_dec
		shl eax,6
      aft_j1:
	     ;;;;;;v = in[i+2]=='=' ? v << 6 : (v << 6) | b64invs[in[i+3]-43];;;;;;;;;;;;;;;;;
		 mov edx,0
         mov si,i_dec
		 mov dl,[ebx+esi+3]
		 cmp edx,'='
		 jne con2_dec
		 shl eax,6  
         jmp aft_con 
	con1_dec:
	    ;;to get this value (v << 6) | b64invs[in[i+2]-43];
	     sub edx,43
		 push eax
		 call b64in
		 mov ret_of_b64in,eax
		 pop eax
		 shl eax,6
		 or eax,ret_of_b64in
		 jmp aft_j1
    con2_dec: 
	     ;;to get this value (v << 6) | b64invs[in[i+3]-43];;
		 sub edx,43
		 push eax
		 call b64in
		 mov ret_of_b64in,eax
		 pop eax
		 shl eax,6
		 or eax,ret_of_b64in
 
	aft_con:
	;;;;;;;;;;;;;;;;;start to add output;;;;;;;;
	   
        mov v,eax
		mov ebx,0
		lea ebx,[ciphertext] 	     
		;;(v>> 16) & 0xFF   this shift to get first 8 values 24-16=8
 		 shr eax,16
		 and eax,255
		 mov esi,0
		 mov si,j_dec
		 mov [ebx+esi],eax
		 mov ebx,0
		;;;;;;;check if (in[i+2] != '=')  if true out[j+1] = (v >> 8) & 0xFF ->  in the label out_con1 ;;;;;;;;;;;
		
		lea ebx,[plaintext]  
		 mov edi,0
		 mov di,i_dec
		 push ebx
		 mov bl,[ebx+edi+2]
         cmp bl,'='
		 pop ebx
		 jne out_con1
 
     ret_from_con1:
	     ;;;;;;;check if (in[i+3] != '=')  if true out[j+1] = (v >> 8) & 0xFF ->  in the label out_con2;;;;;;;;;;;
		 mov ebx,0
		 lea ebx,[plaintext] 
         mov edi,0
		 mov di,i_dec
		 push ebx
		 mov bl,[ebx+edi+3]
         cmp bl,'='
		 jne out_con2
		 pop edx
         jmp end_of_l2
  out_con1:
	   mov eax,v
	   shr eax,8
	   and eax,255
	   mov ebx,0
	   lea ebx,[ciphertext]  	
	   mov esi,0
	   mov si,j_dec
	   mov [ebx+esi+1],eax
	   jmp ret_from_con1
 out_con2: 
       mov eax,v
	   and eax,255
	   mov ebx,0
	  lea ebx,[ciphertext] 
	   mov esi,0
	   mov si,j_dec
	   mov [ebx+esi+2],eax
end_of_l2:
       ;;;; i+=4, j+=3;;;;;;;
	   mov eax,0
	   mov ax,i_dec
	   add eax,4
	   mov i_dec,ax
	   add j_dec,3
	   cmp eax,len
	   jl decode_l2
	   je ret1
	   jg ret1 
 
	ret0:
	    mov ret_of_decode,0
	     mov esp,ebp			  ; Reset the stack pointer
		pop ebp
		ret
 
    ret1:
	    mov ret_of_decode,1
	    mov esp,ebp			  ; Reset the stack pointer
		pop ebp
		ret
 
 
b64_decode  endp
 b64in PROC
 ;;;;;;;;;;to check where index is in  the b64invs   we divide it into 3arr first 27 sec 27 ,third 26;;;;;;;;
	   cmp dl,27
	   jl value1
	   cmp edx,54
	   jl value2
	   jg value3
 
	value1:
	   mov ecx,0
	   lea ecx,[b64invs1]
	   xor eax,eax
	   mov al,[ecx+edx]       
       ret	
	value2:
	   mov ecx,0
	   sub edx,27
	   lea ecx,[b64invs2]
	   xor eax,eax
       mov al,[ecx+edx]
	   ret
	value3:
	   mov ecx,0
	   sub edx,54
	   lea ecx,[b64invs3]
	   xor eax,eax
       mov al,[ecx+edx]
	   ret
b64in endp
 
 

;-----------------------------
;reading int.  procedure
;Receives: address of variable in ebx
;returns ; the value in the address ob ebx
;POST COND. : value taken 
;-----------------------------
reading proc
	push eax
	; reading input		
read:  call ReadInt  ; if OF=0 , that means that it's a good input and eax conatins a valid binary value , sf=sign 
       jno  goodInput
	   mWriteLn" "
       mov  edx,OFFSET promptBad ; if it got here , that means that OF =1 and eax =0 ;(invalid input)
	   mWriteLn" "
       call WriteString
       jmp  read        ;go input again

goodInput:
       mov  [ebx],eax  ;store good value
	   pop eax
	   ret
reading endp
;-----------------------------
;copy a string  procedure
;Receives: addresses of the two strings in eax, ebx 
;returns ; none
;POST COND. : string copied to the address in ebx 
;-----------------------------
copystr proc
	cld
	pusha
	mov ecx,255
	l2: ; this loop is to zero the string u wanna copy to , to remove any invalid chars from before
		mov BYTE PTR [ebx +ecx],0
		loop l2

	mov esi , eax
	call strlen
	movzx ecx, al
	mov edi , ebx 
	rep  movsb
	popa
	ret

copystr endp


end main
