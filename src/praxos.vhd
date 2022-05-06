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


entity praxos is
port(
	clk : in std_logic;
	port_addr : out std_logic_vector(15 downto 0);
	port_out : out std_logic_vector(31 downto 0);
	port_in0 : in std_logic;
	port_wr : out std_logic;
	port_rd : out std_logic
);
end entity praxos;

architecture rtl of praxos is

	component soc is
	port (
		clk_clk       : in  std_logic                     := '0';             --   clk.clk
		io_port_addr  : out std_logic_vector(15 downto 0);                    --    io.port_addr
		io_port_in    : in  std_logic_vector(31 downto 0) := (others => '0'); --      .port_in
		io_port_out   : out std_logic_vector(31 downto 0);                    --      .port_out
		io_port_rd    : out std_logic;                                        --      .port_rd
		io_port_wr    : out std_logic;                                        --      .port_wr
		reset_reset_n : in  std_logic                     := '0'              -- reset.reset_n
	);
	end component;
	
	signal port_in : std_logic_vector(31 downto 0) := (others => '0');

begin

	qsys : soc
	port map(
		clk_clk       => clk,
		io_port_addr  => port_addr,
		io_port_in    => port_in,
		io_port_out   => port_out,
		io_port_rd    => port_rd,
		io_port_wr    => port_wr,
		reset_reset_n => '1'
	);
	
	port_in(0) <= port_in0;


end architecture rtl;