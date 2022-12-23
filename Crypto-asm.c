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
size_t b64_decoded_size(const char *in)
{
	size_t len;
	size_t ret;
	size_t i;

	if (in == NULL)
		return 0;

	len = strlen(in);
	ret = len / 4 * 3;

	for (i=len; i-->0; ) {
		if (in[i] == '=') {
			ret--;
		} else {
			break;
		}
	}

	return ret;
}

int b64invs[] = { 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58,
	59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5,
	6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
	21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28,
	29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
	43, 44, 45, 46, 47, 48, 49, 50, 51 };

	int b64_isvalidchar(char c)
{
	if (c >= '0' && c <= '9')
		return 1;
	if (c >= 'A' && c <= 'Z')
		return 1;
	if (c >= 'a' && c <= 'z')
		return 1;
	if (c == '+' || c == '/' || c == '=')
		return 1;
	return 0;
}

int b64_decode(const char *in, unsigned char *out, size_t outlen)
{
	size_t len;
	size_t i;
	size_t j;
	int    v;

	if (in == NULL )
		return 0;

	len = strlen(in);
	if (len % 4 != 0)
		return 0;

	for (i=0; i<len; i++) {
		if (!b64_isvalidchar(in[i])) {
			return 0;
		}
	}

	for (i=0, j=0; i<len; i+=4, j+=3) {
		v= b64invs[in[i]-43];
		v = (v << 6) | b64invs[in[i+1]-43];
		v = in[i+2]=='=' ? v << 6 : (v << 6) | b64invs[in[i+2]-43];
		v = in[i+3]=='=' ? v << 6 : (v << 6) | b64invs[in[i+3]-43];

		out[j] = (v >> 16) & 0xFF;
		if (in[i+2] != '=')
			out[j+1] = (v >> 8) & 0xFF;
		if (in[i+3] != '=')
			out[j+2] = v & 0xFF;
	}

	return 1;
}




