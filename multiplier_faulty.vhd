----------------------------------------------------------------------------------
-- Assignment SSDS, Andrea Floridia S224906
-- Multiplier with fault
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------
------------------------------------------------------

entity multiplier_faulty is
	port (
    clk : in std_logic;
    a : in std_logic_vector(15 downto 0);
    b : in std_logic_vector(15 downto 0);
    p : out std_logic_vector(31 downto 0)
  );
end multiplier_faulty;

------------------------------------------------------
------------------------------------------------------

architecture behavioral of multiplier_faulty is

------------------------------------------------------
-- Components Declaration
------------------------------------------------------

------------------------------------------------------
-- Multiplier
------------------------------------------------------
component multiplier is
  port (
    clk : in std_logic;
    a : in std_logic_vector(15 downto 0);
    b : in std_logic_vector(15 downto 0);
    p : out std_logic_vector(31 downto 0)
  );
end component;

------------------------------------------------------
-- Internal Signal
------------------------------------------------------
signal p_fault : std_logic_vector(31 downto 0);

begin

	MULT_0: multiplier port map (clk, a, b, p_fault);
	
	p <= p_fault or "00000000000000000000000000000001";


end behavioral;

