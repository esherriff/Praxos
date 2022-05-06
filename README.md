# Praxos Functional Description

## Overview
The Praxos is a 32-bit soft core processor written in VHDL which has been designed for use as a flexible DMA controller in Avalon bus fabrics. The core’s feature set is inspired by the Microsemi coreABC AMBA bus controller, though the actual instruction set and architecture are based more upon the 8-bit Picoblaze and 16-bit Leros architectures.
The Praxos instruction set provides direct access to a 32-bit Avalon memory mapped master interface, while also using faster internal program and data memory. To minimize logic usage the core is an accumulator-based architecture with a register-memory style instruction set.
Features
- 34 instructions with 3 address modes, branch instructions with most instructions requiring 3 clock cycles to execute (excluding branches, data memory reads and Avalon bus operations).
- 232x36-bit program memory address space.
- 228x32-bit data memory address space.
- 216x32-bit IO address space (expandable to 232x32-bit).
- 32-bit accumulator and 32-bit index register.
- Direct, indirect (with offset) and immediate addressing modes.
- 32-bit Avalon memory mapped master.

A typical Praxos core requires 450 logic elements and will run at over 80MHz in a Cyclone 10LP FPGA.

## Architecture

The partial block diagram below shows the basic layout of the core.

![alt_text](http://github.com/esherriff/Praxos/blob/main/docs/Block_diagram.png?raw=true)

The design makes use of the output registers within the program memory block RAM, which serve as an instruction register. The control signals from the FSM are registered to improve timing. The data RAM output registers are also used, which incurs an additional clock cycle delay to operations that read from data memory.

Each instruction is encoded as a single 36-bit word, which permits the loading of immediate 32-bit operands into the accumulator and index registers. The majority of instructions require 3 clock cycles to execute, branches and data memory reads take 4 cycles. Avalon bus operations require a minimum of 5 clock cycles, assuming zero wait states.

Not shown on the block diagram is the branch unit or the negative flags, which are simply the top bit of the respective register. Four flags are implemented, accumulator zero (AZ), accumulator negative (AN), index negative (IN) and IO zero (IOZ). The number of bits evaluated by the IO zero flag is configured via the IO_FLAG_WIDTH generic, which sets the number of bits tested starting from the lsb of port_in (1 to 32).

The depth of the program and data memories are also configured by generics. The program memory address width; PM_WIDTH is configurable between 8 and 32 bits. DM_WIDTH sets the data memory address width between 8 and 28 bits. In reality it is expected that only small memories would be utilised, with the default 8 bits corresponding to a single M9k block for each memory.

## Registers

Praxos programs rely on manipulating just two 32-bit registers, an accumulator and an index register. The index register is used only to generate addresses for the data memory and Avalon bus. When used in combination with a location in data memory, the index register can be used as a stack pointer to implement subroutines.

## Arithmetic and Logic Unit

The ALU has three basic modes of operation: addition/subtraction, shifting/rotation and bit-wise logical. All ALU results are stored in the accumulator.

## Input/Output (IO) Ports

Praxos supports 65536 32-bit IO locations, which may be used to attach additional hardware to the processor. This IO port can be used to attach the Praxos to a larger, master processor, either as an Avalon slave or directly to the master’s memory bus.

## Instruction Set

The table below summarises the instructions implemented.

| Asssembler Mnemonic | Description | Flags Affected |
| ------------------- | ----------- | -------------- |
| a) ADD K <br><br>b) ADD# K  | a) Adds the contents of data memory address K  to the accumulator.<br><br> b) Adds the immediate operand K to the accumualtor. K is a 28-bit unsigned value |  AZ <br><br> AN |
| a) SUB K <br><br>b) SUB# K | a) Subtracts the contents of data memory address K from the accumulator.<br><br>b) Subtracts the immediate operand K from the accumulator. K is a 28-bit unsigned value. |  AZ <br><br> AN |
| a) BUSR K <br><br>b) BUSRBx K<br><br>c) BUSRHx K<br><br>d) BUSRW K | a) Reads a value from the Avalon bus at address I + K(27 downto 0) to the accumulator. K(31 downto 28) sets the bus byte enable.<br><br>b) x = 0-3, reads a 32-bit value from Avalon address I+K to the accumulator. x sets the byte lane enabled.<br><br>c) x = 0-1, reads a 32-bit value from Avalon address I+K to the accumulator. x sets the half word enabled on the Avalon bus (upper or lower).<br><br>d) Reads a 32-bit value from Avalon address I+K to the accumulator. All byte lanes are enabled. |  AZ <br><br> AN |
| a) BUSW K <br><br>b) BUSWBx K<br><br>c) BUSWHx K<br><br>d) BUSWW K | a) Writes the accumulator to the Avalon bus at address index + K(27 downto 0). K(31 downto 28) sets the bus byte enable.<br><br>b)  x = 0-3, Writes the accumulator to Avalon address index+K to the accumulator. x sets the byte lane enabled.<br><br>c)  x = 0-1, writes the accumulator to Avalon address index+K to the accumulator. x sets the half word enabled on the Avalon bus (upper or lower).<br><br>d) Writes the accumulator to Avalon address index+K. All byte lanes are enabled. |  AZ <br><br> AN |
| LD# K  | Loads the accumulator with the 32-bit constant K. |  AZ <br><br> AN |
| a) LD K <br><br>b) LDI K  | Loads the accumulator with the contents of data memory location (a) K or (b) the index register+K . The result is stored in the accumulator. |  AZ <br><br> AN |
| a) AND K <br><br>b) ANDI K  | Performs the logical AND of the accumulator with the contents of data memory location (a) K or (b) the index register + K . The result is stored in the accumulator. |  AZ <br><br> AN |
| a) OR K <br><br>b) ORI K  | Performs the logical OR of the accumulator with the contents of data memory location (a) K or (b) the index register + K . The result is stored in the accumulator. |  AZ <br><br> AN |
| a) XOR K<br><br>b) XORI K  | Performs the logical XOR of the accumulator with the contents of data memory location (a) K or (b) the index register + K . The result is stored in the accumulator. |  AZ <br><br> AN |
| a) SHL0<br><br>b) SHL1<br><br>c) SHLX  | Shifts the accumulator left by one bit. The least significant bit is set to (a) 0, (b) 1 or (c) left unchanged. |  AZ <br><br> AN |
| ROL  | Rotates the accumulator left by one bit. |  AZ <br><br> AN |
| a) SHR0<br><br>b) SHR1<br><br>c) SHRX  | Shifts the accumulator right by one bit. The most significant bit is set to (a) 0, (b) 1 or (c) left unchanged. |  AZ <br><br> AN |
| ROR  | Rotates the accumulator right by one bit. |  AZ <br><br> AN |
| OUT K | Writes the accumulator to the output port specified by K. |  - |
| IN K | Reads the value from the IO port specified by K to the accumulator. |  AZ <br><br> AN |
| a) ST K <br><br>b) STI K  | a) Stores the accumulator to data memory location (a) K or (b) I + K. | - |
| ILD K  | Loads the index register with the contents of data memory location K. |  IN |
| ILD# K  | Loads the index register with the 32-bit constant K. |  IN |
| IST K  | Writes the index register to data memory location K. |  - |
| IADD# K  | Adds the 32-bit constant K to the index register. |  IN |
| PUSH | Decrements the index register then writes the accumulator to data memory location specified by the index register. |  IN |
| POP | Writes the contents of data memory location specified by the index register to the accumulator, then increments the index register. |  IN |
| JAL K | Jump and Link. Writes the program counter to data memory location index+K, then writes the accumulator to the program counter. | - |
| BR K | Branch always. Adds the signed 28-bit constant K to the program counter. | - |
| BRZ K | If the accumulator = 0, adds the signed 28-bit constant K to the program counter. | - |
| BRNZ K | If the accumulator &ne; 0, adds the signed 28-bit constant K to the program counter. | - |
| BRP K | If the accumulator msb = 0, adds the signed 28-bit constant K to the program counter. | - |
| BRN K | If the accumulator msb = 1, adds the signed 28-bit constant K to the program counter. | - |
| BRIN K | If the index register msb = 1, adds the signed 28-bit constant K to the program counter. | - |
| BRIO K | If port_in(IO_FLAG_WIDTH-1 downto 0) = 0, adds the signed 28-bit constant K to the program counter. | - |
| NOP | No operation, 4 clock cycles (implemented internally as branch never). | - |

##Praxis Assembler

The assembler converts text files (.asm) containing assembly instructions and directives into a Memory Initialisation File (MIF), Mentor memory file (MEM) and a VHDL application image file.
A program is assembled by running praxis.exe <filename> <PM_WIDTH>
Where <filename> specifies the file to be assembled and PM_WIDTH specifies the width of the program memory address bus. Any assembly errors will be written to the console.
The VHDL application image contains a vendor agnostic VHDL package that can initialise the program memory. It also doubles as a listing file by providing the assembly listing as VHDL comment next to the corresponding opcode.

###Directives

Directives are used to instruct the assembler how to assemble the program. All directives are prefixed with a period character (.).

Currently the assembler only supports one directive, .EQU. Which is used to define a numerical value to an alphanumeric reference in the form .EQU X Y, where X is the label and Y is the value. .EQU is used to both label locations in data memory or constant values, depending upon the addressing mode of the instruction in which they appear as an operand.

###Operators and functions

Currently the assembler supports only numerical constant values in decimal or hexadecimal format. Hexadecimal values must be prefixed with a $ character.

###Labels

Labels are used to refer to program locations symbolically. A label consists of a @ character followed by an alphanumeric string. A line containing a label must also contain a valid assembly instruction, an otherwise empty line cannot be labelled.

###Comments

Comments are initiated with a ; character and terminate at the next line break.

###Jump and Link

The Praxos processor does not implement a traditional call stack using call and return operations. Instead it uses a single instruction JAL which can serve as both a call or return operation when used appropriately in combination with operations on the index register. It is recommended that a data memory location be allocated for use as a stack pointer so that the index register can be used for other purposes besides maintaining the stack.

The JAL instruction accepts an operand in the form of an offset to the index register though it does not update the index register, this must be done using a separate IADD# instruction to update the index register following a call or return.

For example the following code implements the equivalent of call and return from a nested subroutines:

```
.EQU sp 0				; allocate a stack pointer at DM(0)
.EQU av_addr1 1			; allocate an Avalon address at DM(1)	
.EQU av_addr2 2			; allocate an Avalon address at DM(1)	
.EQU mask1 3			; some more variables
.EQU	mask2 4
.EQU io 5
.EQU call_ret -1			; handy constant

		ld#	$80000000	; load a constant
		st	mask1		; store it
		ror
		st	mask2
		ld#	0		; load accumulator
		st	sp		; initialise stack pointer
@main	ild	sp		; load the index register with sp
		ld#	10		; load subroutine parameter
		push			; push the parameter
		ld#	dec		; point the accumulator at @dec
		jal	call_ret	; jump, link to sp-1
		iadd#	1		; clear the parameter we pushed
		ist	sp		; save the stack pointer
; do some unrelated stuff with the index register
		ild	av_addr1	; load first Avalon address
		busrw	0		; read from it
		iadd#	4		; increment address
		ist	av_addr1	; store address
		ldi	av_addr2	; load second Avalon address
		busww	0		; write to it
		iadd#	-4		; decrement address
		ist	av_addr2	; store address
		ild	sp		; load the stack pointer
; call from here as well
		ld	mask2		; load a bit mask
		push			; push bit mask
		ld#	tog		; point at tog
		jal	call_ret	; call
		iadd#	1		; clear the parameter we pushed*
		br	main		; jump
; subroutine1
@dec		ldi	0		; load the parameter
@dec_lp	sub#	1		; decrement the parameter
		brnz	dec_lp	; loop until zero
		iadd#	call_ret	; push parent return address†
		ld	mask1		; load parameter
		push			; push parameter
		ld#	tog		; point at @tog
		jal	call_ret	; call
		iadd#	1		; clear pushed parameter*
		pop			; pop return address
		jal	call_ret	; return
; subroutine2
@tog		ldi	0		; load parameter
		xor	io		; xor mask with data
		out	0		; write to IO port
		st	io		; store data
		ldi	call_ret  	; pop return address
		jal	call_ret	; return
```

As can be seen from the above code, intelligent use of indexed addressing modes allows the management of both a call stack and stack frame. Functions may also push return values onto the stack before returning to the caller, return values can be saved to location -2 using sti and retrieved by the caller using ldi. Two important principles apply; first, that a subroutine that needs to perform a call allocate stack space for its caller’s return address (lines marked with †). Second, that any code that pushed parameters onto the stack before a call must clear them from the stack when the function returns (line marked with *). Both operations are conducted by simply updating the index register using the IADD# instruction.

When switching the index register to another purpose, it is stored to the sp location in data memory and restored afterwards.

###Conclusion

A design for a small 32-bit CPU has been presented which fills the requirements for a means to rapidly move data around an Avalon bus. There are several areas that would benefit from further work:

1. The existing Praxis assembler lacks many useful features, such as support for arithmetic expressions or conditional assembly.

2. Integration with the Neo430 as a new IO peripheral with corresponding C driver should also be considered.

3. A testbench disassembler for RTL simulation of the core should be written.