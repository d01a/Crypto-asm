# Crypto-asm

## Project description
Implementation of Some **encryption/Encoding** routines: 
1. ROT13
2. RC4
3. Base64

![overview](img/overview)


### Features
The User can:
1. Choose from one of these Routines. 
2. Use Multi stage Encryption By redirecting the output of one stage to the next stage.

### Usage 
- Main menu

![](img/2022-12-22%2017_34_12-D__CS_Micro_Project_Test_Debug_Project.exe.png)

- RO13 choice

![](img/ROT13.png)

Cyberchef output

![](img/ROT13_cyberchef.png)

- Redirection the output to Next stage

![](img/redir.png)

- Cyberchef Output

![](img/redir_cyberchef.png)


<hr>

### Brief Description

1. ROT13
is a simple letter substitution cipher that replaces a letter with the 13th letter after it in the alphabet 
Because there are 26 letters (2×13) in the basic Latin alphabet, ROT13 is its own inverse; that is, to undo ROT13, the same algorithm is applied, so the same action can be used for encoding and decoding.

![ROT13](https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/ROT13_table_with_example.svg/1920px-ROT13_table_with_example.svg.png)

> C code
```C
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
```

2. RC4 

<p align="center">
	<img src = "img/55-2.png"/>
</p>

RC4, is a stream cipher created in 1987. A stream cipher is a type of cipher that operates on data a byte at a time to encrypt that data. RC4 is one of the most commonly used stream ciphers, having been used in Secure Socket Layer (SSL)/ Transport Layer Security (TLS) protocols. 
RC4 generates a pseudorandom stream of bits (a keystream). As with any stream cipher, these can be used for encryption by combining it with the plaintext using bit-wise exclusive-or; decryption is performed the same way (since exclusive-or is a symmetric operation). (This is similar to the Vernam cipher except that generated pseudorandom bits, rather than a prepared stream, are used.) To generate the keystream, the cipher makes use of a secret internal state which consists of two parts:
1. A permutation of all 256 possible bytes (denoted "S" below).
2. Two 8-bit index-pointers (denoted "i" and "j").

![RC4](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/RC4.svg/1920px-RC4.svg.png)

> The key-scheduling algorithm (KSA)
```
for i from 0 to 255
    S[i] := i
endfor
j := 0
for i from 0 to 255
    j := (j + S[i] + key[i mod keylength]) mod 256
    swap values of S[i] and S[j]
endfor
```
> The pseudo-random generation algorithm (PRGA)
```
i := 0
j := 0
while GeneratingOutput:
    i := (i + 1) mod 256
    j := (j + S[i]) mod 256
    swap values of S[i] and S[j]
    K := S[(S[i] + S[j]) mod 256]
    output K
endwhile
```

3. Base64
Base64 is a group of binary-to-text encoding schemes that represent binary data (more specifically, a sequence of 8-bit bytes) in sequences of 24 bits that can be represented by four 6-bit Base64 digits 
Each Base64 digit can take on 64 different values, encoding 6 bits of data. Which characters are chosen to represent the 64 values varies between implementations. The general strategy is to choose 64 characters that are common to most encodings and that are also printable. This combination leaves the data unlikely to be modified in transit through information systems, such as email, that were traditionally not 8-bit clean. For example, MIME's Base64 implementation uses A–Z, a–z, and 0–9 for the first 62 values 

![Base64](https://www.base64code.com/images/magnificent-decode.png)


|Index|	Binary|	Char | Index|	Binary| Char| Index| Binary| char|Index|Binary |Char|
|-----|-------|------|------|---------|-----|------|-------|-----|-----|-------|----|
|0	|000000| A| 16|	010000|	Q|  32	|100000| g|	48|	110000|w|
|1	|000001| B| 17|	010001|	R|  33	|100001| h|	49|	110001|x|
|2	|000010| C| 18|	010010|	S|  34	|100010| i|	50|	110010|y|
|3	|000011| D| 19|	010011|	T|  35	|100011| j|	51|	110011|z|
|4	|000100| E| 20|	010100|	U|  36	|100100| k|	52|	110100|0|
|5	|000101| F| 21|	010101|	V|  37	|100101| l|	53|	110101|1|
|6	|000110| G| 22|	010110|	W|  38	|100110| m|	54|	110110|2|
|7	|000111| H| 23|	010111|	X|  39	|100111| n|	55|	110111|3|
|8	|001000| I| 24|	011000|	Y|  40	|101000| o|	56|	111000|4|
|9	|001001| J| 25|	011001|	Z|  41	|101001| p|	57|	111001|5|
|10	|001010| K| 26|	011010|	a|  42	|101010| q|	58|	111010|6|
|11	|001011| L| 27|	011011|	b|  43	|101011| r|	59|	111011|7|
|12	|001100| M| 28|	011100|	c|  44	|101100| s|	60|	111100|8|
|13	|001101| N| 29|	011101|	d|  45	|101101| t|	61|	111101|9|
|14	|001110| O| 30|	011110|	e|  46	|101110| u|	62|	111110|+|
|15	|001111| P| 31|	011111|	f|  47	|101111| v|	63|	111111|/|
|Padding|=|

<hr>

## Team Members

1. [Ibrahim Yasser](https://github.com/ibrahemyasser)
2. [Ahmed Sayed](https://github.com/ahmed1958)
3. [Ahmed Mohammed Awwad](https://github.com/Ahmed-Awwad99)
4. [Ahmed Mohammed Ali](https://github.com/ahmedmalii)
5. [Mohamed Adel](https://github.com/d01a)

