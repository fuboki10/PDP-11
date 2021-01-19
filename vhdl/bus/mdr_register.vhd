LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY mdr_register IS
GENERIC (n : integer := 32);
PORT(Clk,Rst,enable_mdr_in, enable_read : IN std_logic;
	bus_line, ram_out : IN std_logic_vector(n-1 DOWNTO 0);
	q : OUT std_logic_vector(n-1 DOWNTO 0));
END mdr_register;
ARCHITECTURE reg OF mdr_register IS
BEGIN
	PROCESS (Clk,Rst)
	BEGIN
		IF Rst = '1' THEN
      q <= (OTHERS=>'0');
    ELSIF enable_read = '1' THEN
      q <= ram_out;
		ELSIF rising_edge(Clk) and enable_mdr_in = '1' THEN
			q <= bus_line;
		END IF;
	END PROCESS;
END reg;