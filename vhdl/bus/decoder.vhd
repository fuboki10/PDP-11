LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ndecoder IS
GENERIC (n : integer := 2);
PORT(enable : IN std_logic;
	input : IN std_logic_vector(n-1 DOWNTO 0);
	output : OUT std_logic_vector((2 ** n)-1 DOWNTO 0));
END ndecoder;
ARCHITECTURE decoder_arch OF ndecoder IS
BEGIN
	process(input, enable)
	begin
		output <= (others => '0');
		output(to_integer(unsigned(input))) <= enable;
	end process;	
END decoder_arch;