LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY circuit IS
PORT(src_enable, dest_enable, rst, clk: in std_logic;
	src_sel, dest_sel: in std_logic_vector(1 downto 0));
END circuit;
ARCHITECTURE circuit_arch OF circuit IS

signal inverted_src_enable, inverted_dest_enable : std_logic;
signal reg0_out, reg1_out, reg2_out, reg3_out, reg4_out, reg5_out, reg6_out, reg7_out, ram_out, bus_line : std_logic_vector(15 downto 0);
signal dest_out, src_out : std_logic_vector(7 downto 0);

component my_nDFF IS
GENERIC (n : integer := 32);
PORT(Clk,Rst,enable : IN std_logic;
	d : IN std_logic_vector(n-1 DOWNTO 0);
	q : OUT std_logic_vector(n-1 DOWNTO 0));
END component;

component ndecoder IS
GENERIC (n : integer := 2);
PORT(enable : IN std_logic;
	input : IN std_logic_vector(n-1 DOWNTO 0);
	output : OUT std_logic_vector((2 ** n)-1 DOWNTO 0));
END component;

component tristate_buffer IS
GENERIC (n : integer := 32);
PORT(c : IN std_logic;
	input : IN std_logic_vector(n-1 DOWNTO 0);
	output : OUT std_logic_vector(n-1 DOWNTO 0));
END component;

component ram IS
	GENERIC(N : INTEGER := 32;
		M: INTEGER := 6);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(M-1 DOWNTO 0);
		datain  : IN  std_logic_vector(N-1 DOWNTO 0);
		dataout : OUT std_logic_vector(N-1 DOWNTO 0));
END component;

signal counter_out : std_logic_vector(10 downto 0);
BEGIN
	PROCESS (clk, rst)
    	VARIABLE cnt : INTEGER RANGE 10 DOWNTO 0;
    	BEGIN
           	IF rising_edge(clk) THEN
                	IF rst = '1' or cnt = 0 THEN
                        	cnt := 10;
                	ELSE
                        	cnt := cnt - 1;
                	END IF;
              	END IF;
        	counter_out <= std_logic_vector(to_unsigned(cnt,11));
       	END PROCESS;
	src_label: ndecoder GENERIC MAP(3) port map(src_enable, src_sel, src_out);
	dest_label: ndecoder GENERIC MAP(3) port map(dest_enable, dest_sel, dest_out);
	reg0_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(0), bus_line, reg0_out);
	reg1_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(1), bus_line, reg1_out);
	reg2_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(2), bus_line, reg2_out);
	reg3_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(3), bus_line, reg3_out);
	reg4_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(4), bus_line, reg4_out);
	reg5_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(5), bus_line, reg5_out);
	reg6_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(6), bus_line, reg6_out);
	reg7_label: my_nDFF GENERIC MAP(16) port map(clk, rst, dest_out(7), bus_line, reg7_out);

	ram_label: ram GENERIC MAP(16,11) port map(clk, inverted_dest_enable, counter_out, bus_line, ram_out);

	inverted_src_enable <= not src_enable;
	inverted_dest_enable <= not dest_enable;

	tristate0_label: tristate_buffer GENERIC MAP(16) port map(src_out(0), reg0_out, bus_line);
	tristate1_label: tristate_buffer GENERIC MAP(16) port map(src_out(1), reg1_out, bus_line);
	tristate2_label: tristate_buffer GENERIC MAP(16) port map(src_out(2), reg2_out, bus_line);
	tristate3_label: tristate_buffer GENERIC MAP(16) port map(src_out(3), reg3_out, bus_line);
	tristate4_label: tristate_buffer GENERIC MAP(16) port map(src_out(4), reg4_out, bus_line);
	tristate5_label: tristate_buffer GENERIC MAP(16) port map(src_out(5), reg5_out, bus_line);
	tristate6_label: tristate_buffer GENERIC MAP(16) port map(src_out(6), reg6_out, bus_line);
	tristate7_label: tristate_buffer GENERIC MAP(16) port map(src_out(7), reg7_out, bus_line);
	tristate8_label: tristate_buffer GENERIC MAP(16) port map(inverted_src_enable, ram_out, bus_line);
END circuit_arch;