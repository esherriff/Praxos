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

entity praxos_dm is
generic(
	DM_WIDTH : positive range 5 to 28 := 8
);
port(
	clk : in std_logic;
	addr : in std_logic_vector(DM_WIDTH-1 downto 0);
	wr : in std_logic;
	wr_data : in std_logic_vector(31 downto 0);
	rd_data : out std_logic_vector(31 downto 0)
);
end entity praxos_dm;

architecture rtl of praxos_dm is

	type dm_type is array (0 to (2**DM_WIDTH)-1) of std_logic_vector(31 downto 0);
	signal dm : dm_type := (others => (others => '0'));
	signal q : std_logic_vector(31 downto 0) := (others => '0');

begin
	
	process
	begin
		wait until rising_edge(clk);
		if(wr = '1') then
			dm(to_integer(unsigned(addr))) <= wr_data;
		end if;
		q <= dm(to_integer(unsigned(addr)));
		rd_data <= q;
	end process;

end architecture rtl;