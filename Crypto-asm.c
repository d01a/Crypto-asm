// C implementation of some pieces of the code 

/*-------------------------RC4-----------------------------*/
// main function is stripped out for now
unsigned char S[256];
unsigned int i, j;

void swap(unsigned char *s, unsigned int i, unsigned int j) {
    unsigned char temp = s[i];
    s[i] = s[j];
    s[j] = temp;
}

/* KSA */
void rc4_init(unsigned char *key, unsigned int key_length) {
    for (i = 0; i < 256; i++)
        S[i] = i;
 
    for (i = j = 0; i < 256; i++) {
        j = (j + key[i % key_length] + S[i]) & 255;
        swap(S, i, j);
    }

    i = j = 0;
}
 
/* PRGA */
unsigned char rc4_output() {
    i = (i + 1) & 255;
    j = (j + S[i]) & 255;

    swap(S, i, j);

    return S[(S[i] + S[j]) & 255];
}


/*------------------------------ROT13-----------------------*/
// text[] should be defined as the same array representing the input, e.g. S[] in RC4 should be the same as text[] here. Same 
char text[256] = {'D','o','L','a','X','.','E'};
void ROT13(char *text){
	int i,n;
	// char ch;
	int len = strlen(text); /*strlen should be implemented too!*/
	for(i=0;i<len;i++){
		n = text[i];
		if (n>=65 && n<=90){
			/*Dealing with Upper case*/
			if(n>=65 && n <= 77){
				/*if the char is between A (65) and M (77) simply add 13, 
				it still didn't exceeded 90 (Z)*/

			n = n+13;
			text[i] = (char)n; 
		}

		else{
			/* chars from N to Z deals with wrapping */
			
			n = n-13;
			text[i] = (char)n;
			}
		}
		else if (n >= 97 && n <=122){
			/*lower case chars*/
			if (n >=97 && n <= 109){
				/*same as in upper case*/
				n=n+13;
				text[i] = (char)n;
			}
			else{
				n=n-13;
				text[i] = (char)n;
			}
		}

	}
}



