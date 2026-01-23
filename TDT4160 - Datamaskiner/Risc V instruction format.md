
### R - type instructions
2 register inputs, one output

| funct7 | rs2    | rs1    | funct3 | rd     | opcode |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 7 bits | 5 bits | 5 bits | 3 bits | 5 bits | 7 bits |
-  Opcode
	- Operation of the instruction
- rd
	- Register destination
- funct3
	- Additional OpCode field
- rs1
	- First register source
- rs2
	- Second register source
- Funct7
	- Additional OpCode field

Not all instructions use the same format, but all are 32 bits


### I-Type instructions
Instructions that use a constant operand
![[Pasted image 20251113160426.png]]

Only 12 bits for imm

### S-type Instructions
Store type instructions
![[Pasted image 20251113160556.png]]

Instead of destination, we are using immediate
Need the extra bits to adress where we are actually storing in the memory space.

### SB - type instructions
Same as S, but the immediate values are interpreted differently. 

### U-type instructions
Upper immediate instructions
![[Pasted image 20251113160838.png]]
