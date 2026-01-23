#### 1
Before I run a program i have to:
- write and edit the code
- compile (source -> object files (.o))
	- gcc -c main.c
- link object files + libraries -> executable
	- gcc main.o -o program
- run the executable
	- ./program

#### 2
The compile can help with syntax errors and type errors. It cannot help with logical errors, runtime bugs. Can use debugger, valgrind

#### 3
debugger, run the program until it crashes and inspect the crash point.

#### 4
a)
pArray stores four struct point, and every field is 0
pArray is a local variable in main, so all content is unitialized.

b)
pArray[1].x = 4. we are touching allocated storage.

c)
int x, y,z = 4 bytes hver
så 12 bytes

0-3x
4-7y
8-11z

z = 1025
1025 = 0x00000401
00 00 04 01


8 = 0x01
9 = 0x04
10 = 0x00
11 = 0x00

![[Pasted image 20260115120901.png]]

så c printer 4

d)
