



.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:dword

.data 
S db 256 dup(?)				; Declaring uninitialized 256 char


.code 

main PROC
	

RC4_Init:
		mov edi, OFFSET S		;Storing the start address of the array in the index register DI
		mov ecx, LENGTHOF S		;storing the length of the array in ecx for loop iterations
		mov eax, 0				;counter

	L1:
		mov [edi],eax			;Storing the value of i to the ith element in the array
		add edi, TYPE S			;TYPE (Return the size of a single element in the array) so we move to the next element in the array
		inc eax					;increment counter
		loop L1					;jump to the loop untill we make 256 iterations to break

	invoke ExitProcess,0
main endp
end main