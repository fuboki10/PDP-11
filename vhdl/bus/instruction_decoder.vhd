LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY instruction_decoder IS
  GENERIC (
    N : INTEGER := 16;
    M : INTEGER := 32);
  PORT (
    clk, enable, rst : IN STD_LOGIC;
    halt : OUT STD_LOGIC;
    ir, flag : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    ir_out_address : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
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
END ENTITY instruction_decoder;

ARCHITECTURE instr_decoder_arch OF instruction_decoder IS
  COMPONENT control_store IS
    GENERIC (
      N : INTEGER := 32;
      M : INTEGER := 8);
    PORT (
      clk : IN STD_LOGIC;
      address : IN STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
      dataout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT ndecoder IS
    GENERIC (n : INTEGER := 2);
    PORT (
      enable : IN STD_LOGIC;
      input : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
      output : OUT STD_LOGIC_VECTOR((2 ** n) - 1 DOWNTO 0));
  END COMPONENT;
  COMPONENT my_nDFF IS
    GENERIC (n : INTEGER := 32);
    PORT (
      Clk, Rst, enable : IN STD_LOGIC;
      d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
      q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
  END COMPONENT;
  SIGNAL micro_ar, pla_signal, control_store_input_address, or_dst, or_1op, or_2op, or_indirect : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL control_word : STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
  SIGNAL single_operand, double_operand, branch, inverted_clk : STD_LOGIC;
  SIGNAL test : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL check : STD_LOGIC;
  -- signal f0
BEGIN

  double_operand <= '1' WHEN ir(15 DOWNTO 12) = "1001" OR ir(15 DOWNTO 12) = "1010" OR ir(15 DOWNTO 12) = "0001"
    OR ir(15 DOWNTO 12) = "0010" OR ir(15 DOWNTO 12) = "0011" OR ir(15 DOWNTO 12) = "0100" OR ir(15 DOWNTO 12) = "0101"
    OR ir(15 DOWNTO 12) = "0110" OR ir(15 DOWNTO 12) = "0111" ELSE
    '0';

  single_operand <= '1' WHEN ir(15 DOWNTO 6) = "0000101000" OR ir(15 DOWNTO 6) = "0000101001" OR ir(15 DOWNTO 6) = "0000101010"
    OR ir(15 DOWNTO 6) = "0000101100" OR ir(15 DOWNTO 6) = "0000110000" OR ir(15 DOWNTO 6) = "0000110010"
    OR ir(15 DOWNTO 6) = "0000110001" OR ir(15 DOWNTO 6) = "0000110100" OR ir(15 DOWNTO 6) = "0000110110" ELSE
    '0';

  branch <= '1' WHEN ir(15 DOWNTO 8) = "00000001"
    OR (ir(15 DOWNTO 8) = "00000010" AND flag(1) = '1')
    OR (ir(15 DOWNTO 8) = "00000100" AND flag(1) = '0')
    OR (ir(15 DOWNTO 8) = "10000001" AND flag(0) = '0')
    OR (ir(15 DOWNTO 8) = "10000010" AND (flag(0) = '0' OR flag(1) = '1'))
    OR (ir(15 DOWNTO 8) = "10000100" AND flag(0) = '1')
    OR (ir(15 DOWNTO 8) = "10000110" AND (flag(0) = '1' OR flag(1) = '1')) ELSE
    '0';

  ir_out_address <= "00000000" & ir(7 DOWNTO 0);

  halt <= '1' WHEN control_word(1) = '1' AND ir = "0000000000000000" ELSE
    '0';

  pla_signal <= "01000001" WHEN double_operand = '1' AND control_word(1) = '1' AND ir(11 DOWNTO 9) = "000" --reg direct
    ELSE
    "01001001" WHEN double_operand = '1' AND control_word(1) = '1' AND ir(11 DOWNTO 9) = "001" --reg indirect
    ELSE
    "01010001" WHEN double_operand = '1' AND control_word(1) = '1' AND ir(11 DOWNTO 10) = "01" --auto increment
    ELSE
    "01100001" WHEN double_operand = '1' AND control_word(1) = '1' AND ir(11 DOWNTO 10) = "10" -- auto decrement
    ELSE
    "01110001" WHEN double_operand = '1' AND control_word(1) = '1' AND ir(11 DOWNTO 10) = "11" -- indexed
    ELSE
    "11000001" WHEN single_operand = '1' AND control_word(1) = '1' AND ir(5 DOWNTO 3) = "000" --reg direct
    ELSE
    "11001001" WHEN single_operand = '1' AND control_word(1) = '1' AND ir(5 DOWNTO 3) = "001" --reg indirect
    ELSE
    "11010001" WHEN single_operand = '1' AND control_word(1) = '1' AND ir(5 DOWNTO 4) = "01" --auto increment
    ELSE
    "11100001" WHEN single_operand = '1' AND control_word(1) = '1' AND ir(5 DOWNTO 4) = "10" -- auto decrement
    ELSE
    "11110001" WHEN single_operand = '1' AND control_word(1) = '1' AND ir(5 DOWNTO 4) = "11" -- indexed
    ELSE
    "00001000" WHEN branch = '1' AND control_word(1) = '1' -- branch
    ELSE
    "00000000";
  or_indirect <= "00000001" WHEN ir(9) = '0' AND (control_word(4 DOWNTO 2) = "101" OR control_word(4 DOWNTO 2) = "010")
    ELSE
    "00000000";
  or_dst <= "00000100" WHEN ir(5 DOWNTO 3) = "000" AND control_word(4 DOWNTO 2) = "001"
    ELSE
    "00000000";
  or_1op <= "000" & NOT ir(9) & '0' & ir(8 DOWNTO 6) WHEN control_word(4 DOWNTO 2) = "011"
    ELSE
    "00000000";
  or_2op <= "0000" & ir(15 DOWNTO 12) WHEN control_word(4 DOWNTO 2) = "100"
    ELSE
    "00000000";
  micro_ar <= or_indirect OR or_dst OR or_1op OR or_2op OR pla_signal OR control_word(28 DOWNTO 21);

  inverted_clk <= NOT clk;
  micro_register : my_nDFF GENERIC MAP(8) PORT MAP(clk, rst, '1', micro_ar, control_store_input_address);
  control_store_label : control_store GENERIC MAP(M, 8) PORT MAP(clk, control_store_input_address, control_word);
  f10_label : ndecoder GENERIC MAP(1) PORT MAP('1', control_word(0 DOWNTO 0), f10);
  f9_label : ndecoder GENERIC MAP(1) PORT MAP('1', control_word(1 DOWNTO 1), f9);
  f8_label : ndecoder GENERIC MAP(3) PORT MAP('1', control_word(4 DOWNTO 2), f8);
  f7_label : ndecoder GENERIC MAP(1) PORT MAP('1', control_word(5 DOWNTO 5), f7);
  f6_label : ndecoder GENERIC MAP(2) PORT MAP('1', control_word(7 DOWNTO 6), f6);
  -- f5_label : ndecoder GENERIC MAP(5) PORT MAP('1', control_word(11 DOWNTO 8), f5);
  f5 <= control_word(11 DOWNTO 8);
  f4_label : ndecoder GENERIC MAP(1) PORT MAP('1', control_word(12 DOWNTO 12), f4);
  f3_label : ndecoder GENERIC MAP(2) PORT MAP('1', control_word(14 DOWNTO 13), f3);
  f2_label : ndecoder GENERIC MAP(3) PORT MAP('1', control_word(17 DOWNTO 15), f2);
  f1_label : ndecoder GENERIC MAP(3) PORT MAP('1', control_word(20 DOWNTO 18), f1);
  -- dataout <= ram(to_integer(unsigned(address)));
END instr_decoder_arch;