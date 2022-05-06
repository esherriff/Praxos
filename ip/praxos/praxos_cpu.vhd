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

entity praxos_cpu is
generic(
	DM_WIDTH : positive range 5 to 28 := 8;
	PM_WIDTH : positive range 5 to 32 := 8;
	IO_FLAG_WIDTH : positive range 1 to 32 := 1
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
end entity praxos_cpu;

architecture rtl of praxos_cpu is

	component praxos_pm is
	generic(
		PM_WIDTH : positive range 5 to 32 := 8
	);
	port(
		clk : in std_logic;
		en : in std_logic;
		addr : in std_logic_vector(PM_WIDTH-1 downto 0);
		data : out std_logic_vector(35 downto 0)
	);
	end component;

	component praxos_dm is
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
	end component;
	
	component praxos_decode is
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
	end component;

	component praxos_alu is
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
	end component;
	
	signal instr : std_logic_vector(6 downto 0);
	-- main registers
	signal pc : std_logic_vector(PM_WIDTH-1 downto 0) := (others => '0');
	signal pc_link : std_logic_vector(PM_WIDTH-1 downto 0) := (others => '0');
	signal acc : std_logic_vector(31 downto 0) := (others => '0');
	signal index : std_logic_vector(31 downto 0) := (others => '0');
	signal av_readdata_int : std_logic_vector(31 downto 0) := (others => '0');
	-- pipelined control signals
	signal dm_wr, acc_en, i_en, alu_sel, branch : std_logic := '0';
	-- bus arbiter
	signal bus_busy, av_write_int, av_read_int : std_logic := '0';
	-- registered flags
	signal zero, io_zero : std_logic := '0';
	-- ALU
	signal adder, logic, shifter : std_logic_vector(31 downto 0);
	signal acc_mux: std_logic_Vector(31 downto 0);
	-- Program memory
	signal pm_data : std_logic_vector(35 downto 0);
	-- Data memory
	signal dm_addr : std_logic_vector(DM_WIDTH-1 downto 0);
	signal dm_wr_data, dm_rd_data : std_logic_vector(31 downto 0);
	-- control signals
	signal reset_sr : std_logic_vector(1 downto 0) := "00";
	signal pm_en, jal, branch_int, pc_inc, alu_sel_int, acc_en_int, i_en_int, port_rd_int, port_wr_int, dm_wr_int, bus_strt : std_logic;

begin

	core : praxos_decode
	port map(
		clk => clk,
		resetn => reset_sr(1),
		instr => instr,
		-- flags
		zero => zero,
		neg => acc(31),
		i_neg => index(31),
		in_zero => io_zero,
		-- register enables
		acc_en => acc_en_int,
		i_en => i_en_int,
		-- PM enable
		pm_en => pm_en,
		-- ALU source
		sel_imm => alu_sel_int,
		-- PC control
		jal => jal,
		branch => branch_int,
		pc_inc => pc_inc,
		-- data memory
		dm_wr => dm_wr_int,
		-- I/O
		port_wr => port_wr_int,
		port_rd => port_rd_int,
		-- Bus
		bus_strt => bus_strt,
		bus_busy => bus_busy,
		av_read => av_read_int
	);
	
	alu : praxos_alu
	port map(
		clk => clk,
		-- decode inputs
		acc_in => acc,
		sel_imm => alu_sel,
		-- immediate operand/ALU op
		imm => pm_data(31 downto 0),
		-- Data memory
		dm_rd_data => dm_rd_data,
		-- ALU outputs
		adder => adder,
		logic => logic,
		shifter => shifter
	);
	
	program_rom : praxos_pm
	generic map(
		PM_WIDTH => PM_WIDTH
	)
	port map(
		clk => clk,
		en => pm_en,
		addr => pc,
		data => pm_data
	);
	
	data_ram : praxos_dm
	generic map(
		DM_WIDTH => DM_WIDTH
	)
	port map(
		clk => clk,
		addr => dm_addr,
		wr => dm_wr,
		wr_data => dm_wr_data,
		rd_data => dm_rd_data
	);
	
	reset_gen : process
	begin
		wait until rising_edge(clk);
		if(resetn = '0') then
			reset_sr <= "00";
		else
			reset_sr <= reset_sr(0) & '1';
		end if;
	end process reset_gen;

	instr <= pm_data(35 downto 29);
	
	dm_data_mux : process(acc, pc_link, pm_data, index)
	begin
		case(pm_data(35 downto 34)) is
		when "01" =>
			if(pm_data(31) = '1') then
				dm_wr_data <= index;
			else
				dm_wr_data <= acc;
			end if;
		when "10" =>
			dm_wr_data(PM_WIDTH-1 downto 0) <= pc_link;
			dm_wr_data(31 downto PM_WIDTH) <= acc(31 downto PM_WIDTH);		
		when others =>
			dm_wr_data <= acc;
		end case;
	end process dm_data_mux;
	
	dm_addr_mux : process(pm_data, index)
		variable y_sxtd : std_logic_vector(31 downto 0);
		variable offset : std_logic_vector(31 downto 0);
	begin
		y_sxtd(15 downto 0) := pm_data(15 downto 0);
		y_sxtd(31 downto 16) := (others => pm_data(15));
		offset := std_logic_vector(unsigned(index) + unsigned(y_sxtd));
		if(pm_data(35)= '1') then
			dm_addr <= offset(DM_WIDTH-1 downto 0);
		else
			dm_addr <= pm_data(DM_WIDTH-1 downto 0);
		end if;
	end process dm_addr_mux;
	
	acc_mux_ctrl : process(instr, logic, adder, shifter, port_in, av_readdata_int)
	begin
		case(instr(6 downto 3)) is
		when X"0" =>
			acc_mux <= adder;
		when X"1" =>
			acc_mux <= av_readdata_int;
		when X"A" =>
			acc_mux <= shifter;
		when X"5" =>
			acc_mux <= port_in;
		when X"3"|X"4"|X"C"|X"D" =>
			acc_mux <= logic;
		when others =>
			acc_mux <= (others => '-');
		end case;
	end process acc_mux_ctrl;
	
	accumulator : process
	begin
		wait until rising_edge(clk);
		if(acc_en = '1') then
			acc <= acc_mux;
		end if;
		if(acc_en = '1') then
			if(acc_mux = X"00000000") then
				zero <= '1';
			else
				zero <= '0';
			end if;
		end if;
	end process accumulator;
	
	index_register : process
		variable w_sxtd : std_logic_vector(31 downto 0);
	begin
		wait until rising_edge(clk);
		w_sxtd(15 downto 0) := pm_data(31 downto 16);
		w_sxtd(31 downto 16) := (others => pm_data(31));
		if(i_en = '1') then
			case(pm_data(35 downto 34)) is
			when "00" =>
				index <= pm_data(31 downto 0);
			when "01" =>
				index <= dm_rd_data;
			when others =>
				index <= std_logic_vector(unsigned(index) + unsigned(w_sxtd));
			end case;
		end if;
	end process index_register;
	
	program_counter : process
	begin
		wait until rising_edge(clk);
		if(reset_sr(1) = '0') then
			pc <= (others => '0');
		elsif(jal = '1') then
			pc <= acc(PM_WIDTH-1 downto 0);
		elsif(branch = '1') then
			pc <= std_logic_vector(unsigned(pc) + unsigned(pm_data(PM_WIDTH-1 downto 0)));
		elsif(pc_inc = '1') then
			pc <= std_logic_vector(unsigned(pc) + 1);
		end if;
		if(jal = '1') then
			pc_link <= std_logic_vector(unsigned(pc) + 1);
		end if;
	end process program_counter;
	
	bus_arbiter : process
	begin
		wait until rising_edge(clk);
		if(bus_busy = '0') then
			bus_busy <= '0';
			av_write_int <= '0';
			av_read_int <= '0';
			if(bus_strt = '1') then
				bus_busy <= '1';
				av_write_int <= pm_data(35);
				av_read_int <= pm_data(32);
			end if;
		elsif(av_waitrequest = '0') then
			av_readdata_int <= av_readdata;
			bus_busy <= '0';
			av_write_int <= '0';
			av_read_int <= '0';
		end if;
	end process bus_arbiter;
	
	input_flag : process
	begin
		wait until rising_edge(clk);
		if(to_integer(unsigned(port_in(IO_FLAG_WIDTH-1 downto 0))) = 0) then
			io_zero <= '1';
		else
			io_zero <= '0';
		end if;
	end process input_flag;
	
	pipeline : process
	begin
		wait until rising_edge(clk);
		branch <= branch_int;
		alu_sel <= alu_sel_int;
		acc_en <= acc_en_int;
		i_en <= i_en_int;
		port_wr <= port_wr_int;
		port_rd <= port_rd_int;
		dm_wr <= dm_wr_int;
	end process pipeline;

	av_read <= av_read_int;
	av_write <= av_write_int;
	port_addr <= pm_data(15 downto 0);
	av_writedata <= acc;
	port_out <= acc;
	av_address <= std_logic_vector(unsigned(index) + unsigned(pm_data(27 downto 0)));
	av_byteenable <= pm_data(31 downto 28);
	
end architecture rtl;