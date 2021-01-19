LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY circuit IS
	PORT (
		rst, clk : IN STD_LOGIC);
END circuit;
ARCHITECTURE circuit_arch OF circuit IS

	SIGNAL pc_out_control, pc_in_control : STD_LOGIC;
	SIGNAL reg0_out, reg1_out, reg2_out, reg3_out, reg4_out, reg5_out, reg6_out, reg7_out, mdr_out, mar_out, ir_out, temp_out, y_out, z_out, flag_out, ram_out, bus_line, flag_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL dest_out, src_out, dest_in, src_in, reg_out_control, reg_in_control : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL alu_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

	COMPONENT my_nDFF IS
		GENERIC (n : INTEGER := 32);
		PORT (
			Clk, Rst, enable : IN STD_LOGIC;
			d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT mdr_register IS
		GENERIC (n : INTEGER := 32);
		PORT (
			Clk, Rst, enable_mdr_in, enable_read : IN STD_LOGIC;
			bus_line, ram_out : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
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

	COMPONENT instruction_decoder IS
		GENERIC (
			N : INTEGER := 16;
			M : INTEGER := 32);
		PORT (
			clk, enable, rst : IN STD_LOGIC;
			ir, flag : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			f10 : OUT STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
			f9 : OUT STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
			f8 : OUT STD_LOGIC_VECTOR((2 ** 3) - 1 DOWNTO 0);
			f7 : OUT STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
			f6 : OUT STD_LOGIC_VECTOR((2 ** 2) - 1 DOWNTO 0);
			f5 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			f4 : OUT STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
			f3 : OUT STD_LOGIC_VECTOR((2 ** 2) - 1 DOWNTO 0);
			f2 : OUT STD_LOGIC_VECTOR((2 ** 3) - 1 DOWNTO 0);
			f1 : OUT STD_LOGIC_VECTOR((2 ** 3) - 1 DOWNTO 0));
	END COMPONENT;
	SIGNAL f10 : STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
	SIGNAL f9 : STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
	SIGNAL f8 : STD_LOGIC_VECTOR((2 ** 3) - 1 DOWNTO 0);
	SIGNAL f7 : STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
	SIGNAL f6 : STD_LOGIC_VECTOR((2 ** 2) - 1 DOWNTO 0);
	SIGNAL f5 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL f4 : STD_LOGIC_VECTOR((2 ** 1) - 1 DOWNTO 0);
	SIGNAL f3 : STD_LOGIC_VECTOR((2 ** 2) - 1 DOWNTO 0);
	SIGNAL f2 : STD_LOGIC_VECTOR((2 ** 3) - 1 DOWNTO 0);
	SIGNAL f1 : STD_LOGIC_VECTOR((2 ** 3) - 1 DOWNTO 0);
	SIGNAL inverted_clk : STD_LOGIC;
BEGIN

	alu_label : alu GENERIC MAP(16) PORT MAP(y_out, bus_line, flag_out, f5, flag_in, alu_out);

	instr_decoder_label : instruction_decoder GENERIC MAP(16, 29) PORT MAP(clk, '1', rst, ir_out, flag_out, f10, f9, f8, f7, f6, f5, f4, f3, f2, f1);

	src_out_label : ndecoder GENERIC MAP(3) PORT MAP(f1(4), ir_out(8 DOWNTO 6), src_out);
	src_in_label : ndecoder GENERIC MAP(3) PORT MAP(f2(4), ir_out(8 DOWNTO 6), src_in);
	dest_out_label : ndecoder GENERIC MAP(3) PORT MAP(f1(5), ir_out(2 DOWNTO 0), dest_out);
	dest_in_label : ndecoder GENERIC MAP(3) PORT MAP(f2(5), ir_out(2 DOWNTO 0), dest_in);

	reg_in_control <= src_in OR dest_in;
	pc_in_control <= reg_in_control(7) OR f2(1);
	reg0_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, reg_in_control(0), bus_line, reg0_out);
	reg1_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, reg_in_control(1), bus_line, reg1_out);
	reg2_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, reg_in_control(2), bus_line, reg2_out);
	reg3_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, reg_in_control(3), bus_line, reg3_out);
	reg4_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, reg_in_control(4), bus_line, reg4_out);
	reg5_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, reg_in_control(5), bus_line, reg5_out);
	reg6_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, reg_in_control(6), bus_line, reg6_out);
	reg7_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, pc_in_control, bus_line, reg7_out);

	mdr_label : mdr_register GENERIC MAP(16) PORT MAP(clk, rst, f3(2), f6(1), bus_line, ram_out, mdr_out);
	mar_label : my_nDFF GENERIC MAP(16) PORT MAP(inverted_clk, rst, f3(1), bus_line, mar_out);
	ir_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, f2(2), bus_line, ir_out);
	temp_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, f3(3), bus_line, temp_out);
	y_label : my_nDFF GENERIC MAP(16) PORT MAP(inverted_clk, rst, f4(1), bus_line, y_out);
	z_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, f2(3), alu_out, z_out);
	flag_label : my_nDFF GENERIC MAP(16) PORT MAP(clk, rst, f10(1), flag_in, flag_out);

	ram_label : ram GENERIC MAP(16, 11) PORT MAP(clk, f6(2), mar_out(10 DOWNTO 0), mdr_out, ram_out);
	inverted_clk <= NOT clk;
	reg_out_control <= src_out OR dest_out;
	pc_out_control <= reg_out_control(7) OR f1(1);
	tristate0_label : tristate_buffer GENERIC MAP(16) PORT MAP(reg_out_control(0), reg0_out, bus_line);
	tristate1_label : tristate_buffer GENERIC MAP(16) PORT MAP(reg_out_control(1), reg1_out, bus_line);
	tristate2_label : tristate_buffer GENERIC MAP(16) PORT MAP(reg_out_control(2), reg2_out, bus_line);
	tristate3_label : tristate_buffer GENERIC MAP(16) PORT MAP(reg_out_control(3), reg3_out, bus_line);
	tristate4_label : tristate_buffer GENERIC MAP(16) PORT MAP(reg_out_control(4), reg4_out, bus_line);
	tristate5_label : tristate_buffer GENERIC MAP(16) PORT MAP(reg_out_control(5), reg5_out, bus_line);
	tristate6_label : tristate_buffer GENERIC MAP(16) PORT MAP(reg_out_control(6), reg6_out, bus_line);
	tristate7_label : tristate_buffer GENERIC MAP(16) PORT MAP(pc_out_control, reg7_out, bus_line);

	tristate9_label : tristate_buffer GENERIC MAP(16) PORT MAP(f1(2), mdr_out, bus_line);
	tristate10_label : tristate_buffer GENERIC MAP(16) PORT MAP(f1(6), temp_out, bus_line);
	tristate11_label : tristate_buffer GENERIC MAP(16) PORT MAP(f1(3), z_out, bus_line);

END circuit_arch;