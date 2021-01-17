LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY partD IS
	GENERIC (n : INTEGER := 16);
	PORT (
		a : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		cin : IN STD_LOGIC;
		s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		cout : OUT STD_LOGIC;
		f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

END ENTITY;

ARCHITECTURE modelD OF partD IS
BEGIN
	WITH s(1) SELECT
		cout <= a(0) WHEN '0',
		a(n - 1) WHEN OTHERS;
	WITH s SELECT
		f <= a(0) & a(n - 1 DOWNTO 1) WHEN "00", -- ROR (Rotate Right) Dst ← [Dst]0 || [Dst]15->1
		a(n - 1) & a(n - 1 DOWNTO 1) WHEN "01", -- ASR (Arithmetic Shift Right) Dst ← [Dst]15 || [Dst]15->1
		a(n - 2 DOWNTO 0) & '0' WHEN "10", -- LSL (Logic Shift Left) Dst ← [Dst] 14->0 || 0 (WRONG IN THE DOC [Dst]0)
		a(n - 2 DOWNTO 0) & a(n - 1) WHEN OTHERS; -- ROL (Rotate Left) Dst ← [Dst] 14->0 || [Dst]15
END ARCHITECTURE;