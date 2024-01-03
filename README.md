# Goal
The goal of this project is to obtain root privilege on a 32-bit Linux system by exploiting vulnerabilities in installed programs.

# Reports

## Victim 1
``` 
/*
 * Victim1 has a classic strcpy() overflow that allows us to overflow as far as we want
 *      the end goal is to overflow the EIP on the stack to reroute the return address
 *      to point to the start of our exploit string and run the shell
 *
 * We achieve this by filling our buffer of 128 with NOPs and inserting the shell code
 *      at the very end of the string. Beyond that is the offset and then our return
 *      address.
 *
 * The offset was found by running the victim in gdb with an input of
 *
 *      "A"*128 + "B"*16
 *
 *      I just kept incrementing B until the return address of the SIGSEGV was '0x42424242'
 *              which indicated I was at the roght spot
 *
 * Then I just had to find an address that landed us somewhere int he NOPs
 *
 *
 * - STACK MEMORY -
 *
 * Overflow Direction
 * ----------------------------->|   |
 *
 * x Bytes                   4B   4B
 * [STACK                  ][EBP][EIP]
 *
 */
```
## Victim 2
```
/*
 * Victim2 contained a off-by-one buffer overflow in the nstrcpy function
 *      where the for loop that copies over the bytes checks if 'i >= strlen(buf)'
 *      which includes the null-terminator and will allow us to overflow
 *
 * Specifically, I overwrote the least significant byte of the EBP (LE) which caused
 *      it to point to memory in the exploit string
 *
 * The EBP register is used to keep track of where the EIP is stored. By altering the LSB
 *      it can be shifted to higher memory.
 *
 * If the exp_str contains the memory address of our string we can point the EBP to it which
 *      will cause the program to return to out shellcode.
 *
 * -----------------------------------------------------------------------------------------
 *
 * Buffer address ~= 0xbfffff15 -> 0xbfffff35 (roughly within NOP Slide)
 * Length of buffer = 200
 * Shellcode len = 46 - 1 (NULL)
 *
 * 201 - 45 - 64 (32 return addresses)
 * 92 NOPs
 *
 */
```
## Victim 3
```
/*
 * Victim3 was compiled in a way that does not push the EBP register to the stack.
 *      This leaves us only with the EIP to work with. This is advantagous for us
 *      as the overflow is only by 4 bytes
 *
 * The exploit is an unrolled for loop that jumps by 4 bytes. Except, again their is
 *      an issue with the comparison; 'i >= len' which lets us to copy 4 bytes past
 *      the end of the string.
 *
 * From there all we need is to set the return address to the start of our exploit string.
 *
 *
 *      - No EBP -
 *
 * overflow -> EIP '0xbfffff25' (example)
 * EIP needs to point to the start of our string to execute
 *
 *  ____________________________
 * [Stack Mem            ][][EIP]
 *  ----------------------------
 *
 *  ----------------
 * \/              ^
 * [Stack Mem] -> [EIP]
 *
 * Exploit string:
 *
 * 63 NOPs + shellcode (46 - 1'NULL') + addresses*9 (36)
 *
 * "0x90"*63 + shellcode (minus NULL) + ret_address*9
 *
 * More NOPs = More space to work with
 *
 * EXPLOIT:
 * for(int i = 0; i <= len; i+=4) {
 *      out[i]   = in[i];
 *      out[i+1] = in[i+1];
 *      out[i+2] = in[i+2];
 *      out[i+3] = in[i+3];
 * }
 *
 * If len = 4 and i = 4 -> buffer = 4
 *      out[4] = in[4];
 *      out[5] = in[5];
 *      out[6] = in[6];
 *      out[7] = in[7];
 *
 * We overflow by 4 bytes :)
 *
 */
```
## Victim 4
```
/*
 * Victim4 has a function that takes in a char* str and a short len
 *
 * foo(char* arg, short arglen);
 * 
 * That checks if arglen is < than the max of 4000
 *         If true it will run memcpy(buf,arg,strlen(arg));
 *
 * A short is 2^16 bits which can be up towards 32_767
 *         If the input str has a size of 32_768 it will overflow the short
 *         to -32_768 causing the check to be valid and memcpy() the entire
 *         buffer and overflow into the EIP.
 *
 * The exploit string only needs to overflow up to the EIP, where it will
 * execute our shell
 *
 */
```
