LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY instruction_decoder IS
  GENERIC (
    N : INTEGER := 16;
    M : INTEGER := 32);
  PORT (
    clk, enable : IN STD_LOGIC;
    ir, flag : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    control_signals : OUT STD_LOGIC_VECTOR(M - 1 DOWNTO 0));
END ENTITY instruction_decoder;

ARCHITECTURE instr_decoder_arch OF instruction_decoder IS
  SIGNAL micro_ar : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL control_word : STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
  SIGNAL check : STD_LOGIC;
BEGIN
  PROCESS (clk) IS
  BEGIN
    IF rising_edge(clk) AND enable = '1' THEN
      CASE ir(15 DOWNTO 8) IS
        WHEN "00000001" =>
          check <= '1';
        WHEN "00000010" =>
          check <= flag(1);
        WHEN "00000100" =>
          check <= NOT flag(1);
        WHEN "10000001" =>
          check <= NOT flag(0);
        WHEN "10000010" =>
          check <= (NOT flag(0)) OR flag(1);
        WHEN "10000100" =>
          check <= flag(0);
        WHEN "10000110" =>
          check <= flag(0) OR flag(1);
        WHEN OTHERS => check <= '0';
      END CASE;
    END IF;
  END PROCESS;

  PROCESS (clk) IS
    VARIABLE micro_ar_var : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    IF rising_edge(clk) AND enable = '1' THEN
      -- WIDE BRANCHING (only if PLA_out == 1)
      CASE ir(15 DOWNTO 12) IS
        WHEN "1001" | "1010" | "0001" | "0010" | "0011"
          | "0100" | "0101" | "0110" | "0111" =>
          micro_ar_var := "01000001"; -- 101 octal
          micro_ar_var(5 DOWNTO 4) := ir(11 DOWNTO 10);
          micro_ar_var(3) := (NOT ir(11)) AND (NOT ir(10)) AND ir(9);
        WHEN OTHERS =>
          NULL;
      END CASE;

      CASE ir(15 DOWNTO 6) IS
        WHEN
          "0000101000" | "0000101001" | "0000101010" | "0000101100"
          | "0000110000" | "0000110010" | "0000110001" | "0000110100" | "0000110110" =>
          micro_ar_var := "11000001"; -- 301 octal
          micro_ar_var(5 DOWNTO 4) := ir(5 DOWNTO 4);
          micro_ar_var(3) := (NOT ir(5)) AND (NOT ir(4)) AND ir(3);
        WHEN OTHERS =>
          NULL;
      END CASE;

      CASE check IS
        WHEN '1' =>
          micro_ar_var := "00001000"; -- 010 octal
        WHEN '0' =>
          micro_ar_var := "00000000"; -- 000 octal
        WHEN OTHERS =>
          NULL;
      END CASE;

      CASE ir(15 DOWNTO 0) IS
        WHEN "0000000000000000" =>
          micro_ar_var := "00010000"; -- 020 octal
        WHEN OTHERS =>
          NULL;
      END CASE;

      -- BIT ORING
      CASE control_word(27 DOWNTO 25) IS --F8
        WHEN "101" | "010" => --ORsin, ORdin
          micro_ar_var(0) := NOT ir(9);
        WHEN "001" => --ORdst
          micro_ar_var(2) := (NOT ir(5)) AND (NOT ir(4)) AND (NOT ir(3));
        WHEN "011" => --OR1op
          micro_ar_var(4) := NOT ir(9);
          --TODO VERY IMPORTANT CHANGE OP CODES OF 1 OP ABOVE
          micro_ar_var(2 DOWNTO 0) := ir(8 DOWNTO 6);
        WHEN OTHERS =>
          NULL;
      END CASE;
      micro_ar <= micro_ar_var;
    END IF;
  END PROCESS;
  -- dataout <= ram(to_integer(unsigned(address)));
END instr_decoder_arch;