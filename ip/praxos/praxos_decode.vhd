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
use ieee.std_logic_arith.all;

-- decode logic

entity praxos_decode is
port(
	clk : in std_logic;
	resetn : in std_logic;
	instr : in std_logic_vector(6 downto 0);
	-- flags
	zero : in std_logic;
	neg : in std_logic;
	i_neg : in std_logic;
	in_zero : in std_logic;
	-- register enables
	acc_en : out std_logic;
	i_en : out std_logic;
	-- PM enable
	pm_en : out std_logic;
	-- ALU source
	sel_imm : out std_logic;
	-- PC control
	jal : out std_logic;
	branch : out std_logic;
	pc_inc : out std_logic;
	dm_wr : out std_logic;
	-- I/O
	port_wr : out std_logic;
	port_rd : out std_logic;
	-- Bus
	bus_strt : out std_logic;
	bus_busy : in std_logic;
	av_read : in std_logic
);
end entity praxos_decode;

architecture rtl of praxos_decode is

	type state is (fetch1, fetch2, execute, bus_op, branch_wait, ram_ld);
	signal current_state, next_state : state;
	
	signal do_branch, branch_en : std_logic;

begin

	state_ff : process
	begin
		wait until rising_edge(clk);
		if(resetn = '0') then
			current_state <= fetch1;
		else
			current_state <= next_state;
		end if;
	end process state_ff;

	nsl : process(current_state, instr, bus_busy, av_read)
	begin
		acc_en <= '0';
		sel_imm <= '0';
		dm_wr <= '0';
		port_rd <= '0';
		port_wr <= '0';
		i_en <= '0';
		pc_inc <= '0';
		pm_en <= '0';
		jal <= '0';
		bus_strt <= '0';
		branch_en <= '0';
		case(current_state) is
		when fetch1 =>
			next_state <= fetch2;
		when fetch2 =>
			pm_en <= '1';
			next_state <= execute;
		when execute =>
			pc_inc <= '1';
			next_state <= fetch1;
			case(instr(6 downto 3)) is
			when X"0" =>		-- add/sub
				if(instr(0) = '0') then
					next_state <= ram_ld;
				end if;
				acc_en <= instr(0);
				sel_imm <= '1';
			when X"1" =>		-- bus read
				bus_strt <= '1';
				next_state <= bus_op;
			when X"2" =>		-- ild#
				i_en <= '1';
			when X"3" =>		-- ld#
				acc_en <= '1';
				sel_imm <= '1';
			when X"4" =>		-- logical memory
				next_state <= ram_ld;
			when X"5" =>		-- IO
				port_wr <= not(instr(2));
				port_rd <= instr(2);
				acc_en <= instr(2);
			when X"6" => 		-- st/ist
				dm_wr <= '1';
			when X"7" =>		-- i load memory
				next_state <= ram_ld;
			when X"8" =>		-- bus write
				bus_strt <= '1';
				next_state <= bus_op;
			when X"9" =>		-- iadd#
				i_en <= '1';
			when X"A" =>		-- shifter
				acc_en <= '1';
			when X"B" =>		-- JAL
				jal <= '1';
				dm_wr <= '1';
			when X"C" =>		-- logical memory indexed
				next_state <= ram_ld;
			when X"D" =>		-- push/pop
				i_en <= '1';
				dm_wr <= instr(2);
				if(instr(2) = '0') then -- pop
					next_state <= ram_ld;
				end if;
			when X"E" =>		-- branch
				branch_en <= '1';
				next_state <= branch_wait;
			when X"F" =>		-- sti
				dm_wr <= '1';
			when others =>			
			end case;
		when ram_ld =>
			acc_en <= not(instr(4));
			i_en <= instr(4);
			next_state <= fetch1;
		when bus_op =>
			acc_en <= av_read;
			if(bus_busy = '1') then
				next_state <= bus_op;
			else
				next_state <= fetch1;
			end if;
		when branch_wait =>
			next_state <= fetch1;
		end case;
	end process nsl;
	
	-- branch 
	branch_ctrl : process(instr, zero, neg, i_neg, in_zero)
	begin
		-- check branch condition
		if(instr(6 downto 3) = X"E") then
			case(instr(2 downto 0)) is
			when "000" =>		-- BRA
				do_branch <= '1';
			when "001" =>		-- BRZ
				do_branch <= zero;
			when "010" =>		-- BRNZ
				do_branch <= not(zero);
			when "011" =>		-- BRP
				do_branch <= not(neg);
			when "100" =>		-- BRN
				do_branch <= neg;
			when "101" =>		-- BRIN
				do_branch <= i_neg;
			when "110" =>		-- BRIO
				do_branch <= in_zero;
			when others =>		-- NOP
				do_branch <= '0';
			end case;
		else
			do_branch <= '0';
		end if;
	end process branch_ctrl;
	
	branch <= do_branch and branch_en;


end architecture rtl;