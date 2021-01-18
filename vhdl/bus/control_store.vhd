LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY control_store IS
	GENERIC (
		N : INTEGER := 32;
		M : INTEGER := 8);
	PORT (
		clk : IN STD_LOGIC;
		address : IN STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
		dataout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END ENTITY control_store;

ARCHITECTURE control_store_arch OF control_store IS

	TYPE ram_type IS ARRAY(0 TO (2 ** M) - 1) OF STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL ram : ram_type;

BEGIN
	dataout <= ram(to_integer(unsigned(address)));
END control_store_arch;