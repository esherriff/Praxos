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
--
library ieee;

use ieee.std_logic_1164.all;

entity praxos_tb is
end entity praxos_tb;

architecture behav of praxos_tb is

	component praxos is
	generic(
		DM_WIDTH : positive range 5 to 28 := 8;
		PM_WIDTH : positive range 5 to 32 := 8;
		IO_FLAG_WIDTH : positive range 1 to 31 := 1
	);
	port(
		clk : in std_logic;
		resetn : in std_logic;
		-- IO
		port_addr : out std_logic_vector(15 downto 0);
		port_rd : out std_logic;
		port_wr : out std_logic;
		port_in : in std_logic_vector(31 downto 0);
		port_out : out std_logic_vector(31 downto 0);
		-- Avalon
		av_address : out std_logic_vector(31 downto 0);
		av_readdata : in std_logic_vector(31 downto 0);
		av_writedata : out std_logic_vector(31 downto 0);
		av_byteenable : out std_logic_vector(3 downto 0);
		av_write : out std_logic;
		av_read : out std_logic;
		av_waitrequest : in std_logic
	);
	end  component;
	
	signal clk : std_logic;
	signal resetn : std_logic := '1';
	signal port_addr : std_logic_vector(15 downto 0);
	signal port_rd : std_logic;
	signal port_wr : std_logic;
	signal port_in : std_logic_vector(31 downto 0) := (others => '0');
	signal port_out : std_logic_vector(31 downto 0);
	
	signal av_address : std_logic_vector(31 downto 0);
	signal av_readdata : std_logic_vector(31 downto 0) := (others => '0');
	signal av_writedata : std_logic_vector(31 downto 0);
	signal av_byteenable : std_logic_vector(3 downto 0);
	signal av_write : std_logic;
	signal av_read : std_logic;
	signal av_waitrequest : std_logic := '1';
	
	signal state : std_logic_vector(1 downto 0) := (others => '0');

begin

	processor : praxos
	generic map(
		DM_WIDTH => 8,
		PM_WIDTH => 8,
		IO_FLAG_WIDTH => 1
	)
	port map(
		clk => clk,
		resetn => resetn,
		-- IO
		port_addr => port_addr,
		port_rd => port_rd,
		port_wr => port_wr,
		port_out => port_out,
		port_in => port_in,
		-- Avalon
		av_address => av_address,
		av_readdata => av_readdata,
		av_writedata => av_writedata,
		av_byteenable => av_byteenable,
		av_write => av_write,
		av_read => av_read,
		av_waitrequest => av_waitrequest
	);
	
	clk_gen : process
	begin
		clk <= '0';
		wait for 31250 ps;
		clk <= '1';
		wait for 31250 ps;
	end process clk_gen;
	
	avalon_slave : process
	begin
		wait until rising_edge(clk);
		case(state) is
		when "00" =>
			av_waitrequest <= '1';
			if((av_read or av_write) = '1') then
				state <= "01";
			end if;
		when "01" =>
			av_waitrequest <= '0';
			av_readdata(31) <= not(av_readdata(31));
			state <= "10";
		when "10" =>
			av_waitrequest <= '1';
			state <= "00";
		when others =>
		end case;
	end process avalon_slave;

end architecture behav;