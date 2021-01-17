LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY partC IS
	GENERIC (n : INTEGER := 16);
	PORT (
		a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		cin : IN STD_LOGIC;
		cout : OUT STD_LOGIC;
		f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

END ENTITY;

ARCHITECTURE modelC OF partC IS
BEGIN
	WITH s SELECT
		cout <= a(0) WHEN "11",
		cin WHEN OTHERS;
	WITH s SELECT
		f <= a OR b WHEN "00",
		a XOR b WHEN "01",
		NOT a WHEN "10",
		'0' & a(n - 1 DOWNTO 1) WHEN OTHERS; --LSR (Logic Shift Right) Dst ← 0 || [Dst] 15->1
END ARCHITECTURE;