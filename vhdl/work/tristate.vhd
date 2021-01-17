LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY tristate_buffer IS
GENERIC (n : integer := 32);
PORT(c : IN std_logic;
	input : IN std_logic_vector(n-1 DOWNTO 0);
	output : OUT std_logic_vector(n-1 DOWNTO 0));
END tristate_buffer;
ARCHITECTURE tristate_arch OF tristate_buffer IS
BEGIN
	output <= input when c  = '1' else (others => 'Z');
END tristate_arch;
