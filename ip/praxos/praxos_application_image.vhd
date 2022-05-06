-- MIT License

-- Copyright (c) 2022 Edward Sherriff

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

library ieee;
use ieee.std_logic_1164.all;

-- Praxos ROM content

package praxos_application_image is

	type application_image_t is array(0 to (2**8)-1) of std_logic_vector(35 downto 0);
	constant application_image : application_image_t := (
		0 => X"380000000", -- 0 			LD#		$80000000
		1 => X"600000003", -- 1 			ST		MASK1
		2 => X"A60000000", -- 2 			ROR
		3 => X"600000004", -- 3 			ST		MASK2
		4 => X"300000000", -- 4 			LD#		0
		5 => X"600000000", -- 5 			ST		SP
		6 => X"700000000", -- 6 @MAIN		ILD		SP
		7 => X"30000000A", -- 7 			LD#		10
		8 => X"D9FFFFFFF", -- 8 			PUSH
		9 => X"30000001C", -- 9 			LD#		DEC
		10 => X"B0000FFFF", -- 10 			JAL		CALL_RET
		11 => X"900010000", -- 11 			IADD#		1
		12 => X"680000000", -- 12 			IST		SP
		13 => X"700000001", -- 13 			ILD		AV_ADDR1
		14 => X"1F0000000", -- 14 			BUSRW		0
		15 => X"900040000", -- 15 			IADD#		4
		16 => X"680000001", -- 16 			IST		AV_ADDR1
		17 => X"C00000002", -- 17 			LDI		AV_ADDR2
		18 => X"8F0000000", -- 18 			BUSWW		0
		19 => X"9FFFC0000", -- 19 			IADD#		-4
		20 => X"680000002", -- 20 			IST		AV_ADDR2
		21 => X"700000000", -- 21 			ILD		SP
		22 => X"400000004", -- 22 			LD		MASK2
		23 => X"D9FFFFFFF", -- 23 			PUSH
		24 => X"300000027", -- 24 			LD#		TOG
		25 => X"B0000FFFF", -- 25 			JAL		CALL_RET
		26 => X"900010000", -- 26 			IADD#		1
		27 => X"E1FFFFFEA", -- 27 			BR		MAIN
		28 => X"C00000000", -- 28 @DEC		LDI		0
		29 => X"0A0000001", -- 29 @DEC_LP		SUB#		1
		30 => X"E5FFFFFFE", -- 30 			BRNZ		DEC_LP
		31 => X"9FFFF0000", -- 31 			IADD#		CALL_RET
		32 => X"400000003", -- 32 			LD		MASK1
		33 => X"D9FFFFFFF", -- 33 			PUSH
		34 => X"300000027", -- 34 			LD#		TOG
		35 => X"B0000FFFF", -- 35 			JAL		CALL_RET
		36 => X"900010000", -- 36 			IADD#		1
		37 => X"D00010000", -- 37 			POP
		38 => X"B0000FFFF", -- 38 			JAL		CALL_RET
		39 => X"C00000000", -- 39 @TOG		LDI		0
		40 => X"4C0000005", -- 40 			XOR		IO
		41 => X"500000000", -- 41 			OUT		0
		42 => X"600000005", -- 42 			ST		IO
		43 => X"C0000FFFF", -- 43 			LDI		CALL_RET
		44 => X"B0000FFFF", -- 44 			JAL		CALL_RET
		others => (others => '0'));
end praxos_application_image;
