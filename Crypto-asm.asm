



.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:dword

.data 
S			db		259 dup(?)				; Declaring uninitialized 256 char.
key			DB		"Secret",0
key_Length	DB		6
i			DW		0
j			DW		0

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
		mov [edi],eax			;Storing the value of i to the ith element in the array
		add edi, TYPE S			;TYPE (Return the size of a single element in the array) so we move to the next element in the array
		inc eax					;increment counter
		loop L1					;jump to the loop untill we make 256 iterations to break

		ret
RC4_Init ENDP
;RC4_Init Procedure end

end main