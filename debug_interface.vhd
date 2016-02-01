------------------------------------------------------
-- Assignment SSDS, Andrea Floridia S224906
-- Debug Interface
------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

------------------------------------------------------
------------------------------------------------------

entity debug_interface is
port (
		command : in std_logic_vector(1 downto 0);
		number_of_errors : in std_logic_vector(15 downto 0);
		data_out_ram : in std_logic_vector(31 downto 0);
		debug_port : out std_logic_vector(31 downto 0)
		);
end debug_interface;


------------------------------------------------------
------------------------------------------------------


architecture Behavioral of debug_interface is

begin

	DBComb_Logic:process(command, number_of_errors, data_out_ram)
	begin
		case command is
			when "00" =>
				debug_port <= (others => 'Z');
			when "01" =>
				debug_port <= data_out_ram;
			when "10" =>
				debug_port(15 downto 0) <= number_of_errors;
				debug_port(31 downto 16) <= (others => '0');
			when "11" =>
				debug_port <= (others => 'Z');
			when others =>
				debug_port <= (others => 'Z');
		end case;
	end process;


end Behavioral;

