LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mdr_register IS
  GENERIC (n : INTEGER := 32);
  PORT (
    Clk, Rst, enable_mdr_in, enable_read : IN STD_LOGIC;
    bus_line, ram_out : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END mdr_register;
ARCHITECTURE reg OF mdr_register IS
BEGIN
  PROCESS (Clk, Rst)
  BEGIN
    IF Rst = '1' THEN
      q <= (OTHERS => '0');
    ELSIF enable_read = '1' THEN
      q <= ram_out;
    ELSIF rising_edge(Clk) AND enable_mdr_in = '1' THEN
      q <= bus_line;
    END IF;
  END PROCESS;
END reg;