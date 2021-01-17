LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY partB IS
	GENERIC (n : INTEGER := 16);
	PORT (
		a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		cin : IN STD_LOGIC;
		cout : OUT STD_LOGIC;
		f : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

END ENTITY;

ARCHITECTURE modelB OF partB IS
	COMPONENT my_adder IS
		PORT (
			a, b, cin : IN STD_LOGIC;
			s, cout : OUT STD_LOGIC);
	END COMPONENT;
	SIGNAL temp : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
	SIGNAL adderCarryInput : STD_LOGIC;
	SIGNAL result, adderInput : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
BEGIN
	WITH s(0) SELECT
	adderInput <= (OTHERS => '0') WHEN '0',
		(OTHERS => '1') WHEN OTHERS;
	adderCarryInput <= (NOT s(0));
	-- ADDER
	f0 : my_adder PORT MAP(a(0), adderInput(0), adderCarryInput, result(0), temp(0));
	loop1 : FOR i IN 1 TO n - 1 GENERATE
		fx : my_adder PORT MAP(a(i), adderInput(i), temp(i - 1), result(i), temp(i));
	END GENERATE;

	WITH s SELECT
		f <= (OTHERS => '0') WHEN "10",
		a AND b WHEN "11",
		result WHEN OTHERS;
	WITH s SELECT
		cout <= temp(n - 1) WHEN "00",
		NOT temp(n - 1) WHEN "01",
		'0' WHEN "10",
		cin WHEN OTHERS;
END ARCHITECTURE;