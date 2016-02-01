------------------------------------------------------
-- Assignment SSDS, Andrea Floridia S224906
-- Down Counter
------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------
------------------------------------------------------

entity down_counter is
port (
			I: in std_logic_vector(15 downto 0);
			tc: out std_logic;
			clk, clr, cnt: in std_logic 
		);
end down_counter;

------------------------------------------------------
------------------------------------------------------


architecture beh of down_counter is

------------------------------------------------------
-- Internal Signal
------------------------------------------------------
	signal q: unsigned(15 downto 0);
begin

	dw_cnt:process (clk)
	begin
		if (clk = '1' and clk'event) then
			if (clr = '1') then
				q <= unsigned(i);
			elsif (cnt = '1') then
				q <= q - 1;
			end if;
		end if;
	end process;
	
	tc <= '1' when (q = "0000000000000000")else '0';
end beh;