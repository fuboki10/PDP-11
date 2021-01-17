LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- flag(0) -> Carry
-- flag(1) -> Zero
-- flag(2) -> Negative
ENTITY alu IS
	GENERIC (n : INTEGER := 16);
	PORT (
		a, b, flag : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		s : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		flagout, f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

END ENTITY;

ARCHITECTURE aluModel OF alu IS
	COMPONENT partA IS
		GENERIC (n : INTEGER := 16);
		PORT (
			a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			cin : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

	END COMPONENT;

	COMPONENT partB IS
		GENERIC (n : INTEGER := 16);
		PORT (
			a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			cin : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

	END COMPONENT;

	COMPONENT partC IS
		GENERIC (n : INTEGER := 16);
		PORT (
			a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			cin : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

	END COMPONENT;

	COMPONENT partD IS
		GENERIC (n : INTEGER := 16);
		PORT (
			a : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
			cin : IN STD_LOGIC;
			s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			cout : OUT STD_LOGIC;
			f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

	END COMPONENT;
	SIGNAL coutA, coutB, coutC, coutD : STD_LOGIC;
	SIGNAL outA, outB, outC, outD, outReg : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

BEGIN
	partALabel : partA GENERIC MAP(n) PORT MAP(a, b, s(1 DOWNTO 0), flag(0), coutA, outA);
	partBLabel : partB GENERIC MAP(n) PORT MAP(a, b, s(1 DOWNTO 0), flag(0), coutB, outB);
	partCLabel : partC GENERIC MAP(n) PORT MAP(a, b, s(1 DOWNTO 0), flag(0), coutC, outC);
	partDLabel : partD GENERIC MAP(n) PORT MAP(a, flag(0), s(1 DOWNTO 0), coutD, outD);

	WITH s(3 DOWNTO 2) SELECT
	outReg <= outA WHEN "00",
		outB WHEN "01",
		outC WHEN "10",
		outD WHEN OTHERS;

	f <= outReg;

	WITH s(3 DOWNTO 2) SELECT
	flagOut(0) <= coutA WHEN "00",
	coutB WHEN "01",
	coutC WHEN "10",
	coutD WHEN OTHERS;

	flagOut(1) <= '1' WHEN outReg = (n - 1 DOWNTO 0 => '0') ELSE
	'0';

	flagOut(2) <= outReg(n - 1);
END ARCHITECTURE;