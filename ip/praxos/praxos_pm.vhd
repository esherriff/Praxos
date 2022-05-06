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

use work.praxos_application_image.all;

entity praxos_pm is
generic(
	PM_WIDTH : positive range 5 to 32 := 8
);
port(
	clk : in std_logic;
	en : in std_logic;
	addr : in std_logic_vector(PM_WIDTH-1 downto 0);
	data : out std_logic_vector(35 downto 0)
);
end entity praxos_pm;


architecture rtl of praxos_pm is
	
	signal rom : application_image_t := application_image;--(others => (others => '0'));
	
	signal q : std_logic_vector(35 downto 0);
	signal data_int : std_logic_vector(35 downto 0) := (others => '0');

begin
	
	process(clk, en)
	begin
		if(rising_edge(clk)) then
			q <= rom(to_integer(unsigned(addr)));
		end if;
		if((en = '1') and rising_edge(clk)) then
			data_int <= q;
		end if;
	end process;
	data <= data_int;

end architecture rtl;