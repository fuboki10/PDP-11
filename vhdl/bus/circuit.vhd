LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY circuit IS
	PORT (
		src_enable, dest_enable, rst, clk : IN STD_LOGIC;
		src_sel, dest_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0));
END circuit;
ARCHITECTURE circuit_arch OF circuit IS

	SIGNAL inverted_src_enable, inverted_dest_enable, inverted_flag_enable, inverted_clk : STD_LOGIC;
	SIGNAL reg0_out, reg1_out, reg2_out, reg3_out, reg4_out, reg5_out, reg6_out, reg7_out, mdr_out, mar_out, ir_out, temp_out, y_out, z_out, flag_out, ram_out, bus_line, temp_flag_out, temp_flag_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL dest_out, src_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL en : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL tri_en : STD_LOGIC_VECTOR(2 DOWNTO 0);

	SIGNAL alu_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL alu_s : STD_LOGIC_VECTOR(3 DOWNTO 0);

	COMPONENT my_nDFF IS
		GENERIC (n : INTEGER := 32);
		PORT (
			Clk, Rst, enable : IN STD_LOGIC;
			d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT ndecoder IS
		GENERIC (n : INTEGER := 2);
		PORT (
			enable : IN STD_LOGIC;
			input : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR((2 ** n) - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT tristate_buffer IS
		GENERIC (n : INTEGER := 32);
		PORT (
			c : IN STD_LOGIC;
			input : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT ram IS
		GENERIC (
			N : INTEGER := 32;
			M : INTEGER := 6);
		PORT (
			clk : IN STD_LOGIC;
			we : IN STD_LOGIC;
			address : IN STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
			datain : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			dataout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT alu IS
		GENERIC (n : INTEGER := 16);
		PORT (
			a, b, flag : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			s : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			flagout, f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

	END COMPONENT;
BEGIN

	alu_label : alu GENERIC MAP(16) PORT MAP(y_out, bus_line, flag_out, alu_s, temp_flag_in, alu_out);

	src_label : ndecoder GENERIC MAP(3) PORT MAP(src_enable, src_sel, src_out);
	dest_label : ndecoder GENERIC MAP(3) PORT MAP(dest_enable, dest_sel, dest_out);
	reg0_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(0), bus_line, reg0_out);
	reg1_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(1), bus_line, reg1_out);
	reg2_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(2), bus_line, reg2_out);
	reg3_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(3), bus_line, reg3_out);
	reg4_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(4), bus_line, reg4_out);
	reg5_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(5), bus_line, reg5_out);
	reg6_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(6), bus_line, reg6_out);
	reg7_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, dest_out(7), bus_line, reg7_out);

	mdr_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, en(0), bus_line, mdr_out);
	mar_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, en(1), bus_line, mar_out);
	ir_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, en(2), bus_line, ir_out);
	temp_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, en(3), bus_line, temp_out);
	y_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, en(4), bus_line, y_out);
	z_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, en(5), alu_out, z_out);
	flag_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, en(6), temp_flag_out, flag_out);

	inverted_flag_enable <= NOT en(6);

	temp_flag_label : my_nDFF GENERIC MAP(16) PORT MAP(inverted_clk, rst, en(5), temp_flag_in, temp_flag_out);
	ram_label : ram GENERIC MAP(16, 16) PORT MAP(clk, inverted_dest_enable, mar_out, mdr_out, ram_out);

	inverted_src_enable <= NOT src_enable;
	inverted_dest_enable <= NOT dest_enable;
	inverted_clk <= NOT clk;

	tristate0_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(0), reg0_out, bus_line);
	tristate1_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(1), reg1_out, bus_line);
	tristate2_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(2), reg2_out, bus_line);
	tristate3_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(3), reg3_out, bus_line);
	tristate4_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(4), reg4_out, bus_line);
	tristate5_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(5), reg5_out, bus_line);
	tristate6_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(6), reg6_out, bus_line);
	tristate7_label : tristate_buffer GENERIC MAP(16) PORT MAP(src_out(7), reg7_out, bus_line);
	tristate8_label : tristate_buffer GENERIC MAP(16) PORT MAP(inverted_src_enable, ram_out, bus_line);

	tristate9_label : tristate_buffer GENERIC MAP(16) PORT MAP(tri_en(0), mdr_out, bus_line);
	tristate10_label : tristate_buffer GENERIC MAP(16) PORT MAP(tri_en(1), temp_out, bus_line);
	tristate11_label : tristate_buffer GENERIC MAP(16) PORT MAP(tri_en(2), z_out, bus_line);

END circuit_arch;