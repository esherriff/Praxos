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
use ieee.numeric_std.all;

entity praxos_alu is
port(
	clk : in std_logic;
	-- decode inputs
	acc_in : in std_logic_vector(31 downto 0);
	sel_imm : in std_logic;
	-- fetch inputs
	imm : in std_logic_vector(31 downto 0);
	-- Data memory
	dm_rd_data : in std_logic_vector(31 downto 0);
	-- ALU outputs
	adder : out std_logic_vector(31 downto 0);
	logic : out std_logic_vector(31 downto 0);
	shifter : out std_logic_vector(31 downto 0)
);
end entity praxos_alu;

architecture rtl of praxos_alu is

	-- operand
	signal opd  : std_logic_vector(31 downto 0);
	signal opd_sxtd  : std_logic_vector(31 downto 0);

begin
	
	operand_mux : process(imm, sel_imm, dm_rd_data)
	begin
		if (sel_imm = '1') then
			opd_sxtd(31 downto 29) <= (others => '0');
			opd_sxtd(28 downto 0) <= imm(28 downto 0);
			opd <= imm;
		else
			opd_sxtd <= dm_rd_data;
			opd <= dm_rd_data;
		end if;
	end process operand_mux;
	
	arithmetic_unit : process(acc_in, opd_sxtd, imm)
	begin
		if(imm(31) = '0') then
			adder <= std_logic_vector(unsigned(acc_in) + unsigned(opd_sxtd));
		else
			adder <= std_logic_vector(unsigned(acc_in) - unsigned(opd_sxtd));
		end if;
	end process arithmetic_unit;
	
	logic_unit : process(imm, opd, acc_in)
	begin
		case(imm(31 downto 30)) is
		when "01" =>
			logic <= acc_in AND opd;
		when "10" =>
			logic <= acc_in OR opd;
		when "11" =>
			logic <= acc_in XOR opd;
		when others => -- load
			logic <= opd;
		end case;
	end process logic_unit;

	barrel_shifter : process(imm, acc_in)
	begin
		case(imm(31 downto 29)) is
		when "000" =>
			shifter <= '0' & acc_in(31 downto 1); -- shr0
		when "001" =>
			shifter <= '1' & acc_in(31 downto 1); -- shr1
		when "010" =>
			shifter <= acc_in(31) & acc_in(31 downto 1); -- shrx
		when "011" =>
			shifter <= acc_in(0) & acc_in(31 downto 1); -- ror
		when "100" =>
			shifter <= acc_in(30 downto 0) & '0'; -- shl0
		when "101" =>
			shifter <= acc_in(30 downto 0) & '1'; -- shl1
		when "110" =>
			shifter <= acc_in(30 downto 0) & acc_in(0); -- shlx
		when others =>
			shifter <= acc_in(30 downto 0) & acc_in(31); -- rol
		end case;
	end process barrel_shifter;
	
	
end architecture rtl;