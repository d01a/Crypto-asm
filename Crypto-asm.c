// C implementation of some pieces of the code 

/*-------------------------RC4-----------------------------*/
// main function is stripped out for now
#define N 256   // 2^8

void swap(unsigned char *a, unsigned char *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

int KSA(char *key, unsigned char *S) {

    int len = strlen(key);
    int j = 0;

    for(int i = 0; i < N; i++)
        S[i] = i;

    for(int i = 0; i < N; i++) {
        j = (j + S[i] + key[i % len]) % N;

        swap(&S[i], &S[j]);
    }

    return 0;
}

int PRGA(unsigned char *S, char *plaintext, unsigned char *ciphertext) {

    int i = 0;
    int j = 0;

    for(size_t n = 0, len = strlen(plaintext); n < len; n++) {
        i = (i + 1) % N;
        j = (j + S[i]) % N;

        swap(&S[i], &S[j]);
        int rnd = S[(S[i] + S[j]) % N];

        ciphertext[n] = rnd ^ plaintext[n];

    }

    return 0;
}

int RC4(char *key, char *plaintext, unsigned char *ciphertext) {

    unsigned char S[N];
    KSA(key, S);

    PRGA(S, plaintext, ciphertext);

    return 0;
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

size_t b64_encoded_size(size_t inlen)
{
	size_t ret;

	ret = inlen;
	if (inlen % 3 != 0)         //7%3 = 1 !=0
		ret += 3 - (inlen % 3); // 7 + 3 => 10-(7%3) ==> 10 - 1 = 9 #
	ret /= 3;                   // 9/3 = 3 
	ret *= 4;                   // 3*4 =12 # -->size<--

	return ret;
}



const char b64chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

char *b64_encode(const unsigned char *in, size_t len)
{
	char   *out;
	size_t  elen;
	size_t  i;
	size_t  j;
	size_t  v;

	if (in == NULL || len == 0)
		return NULL;

	elen = b64_encoded_size(len); 
	out  = malloc(elen+1);
	out[elen] = '\0';

	for (i=0, j=0; i<len; i+=3, j+=4) {// len --> size of the input ex: "Ahmed" --> 5 #
		v = in[i];
		v = i+1 < len ? v << 8 | in[i+1] : v << 8;  1111 1111 0000 0000
		v = i+2 < len ? v << 8 | in[i+2] : v << 8;                 1111 1111
                                                    1111 1111 1111 1111 0000 0000 
                                                    1                    1111 1111
                                                    

		out[j]   = b64chars[(v >> 18) & 0x3F];      0011 1111  // 3f --> 0011 1111
		out[j+1] = b64chars[(v >> 12) & 0x3F];
		if (i+1 < len) {
			out[j+2] = b64chars[(v >> 6) & 0x3F];
		} else {
			out[j+2] = '=';
		}
		if (i+2 < len) {
			out[j+3] = b64chars[v & 0x3F];
		} else {
			out[j+3] = '=';
		}
	}

	return out;
}




