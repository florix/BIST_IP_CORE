------------------------------------------------------
-- Assignment SSDS, Andrea Floridia S224906
-- Top Level Entity
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


------------------------------------------------------
------------------------------------------------------

entity top_level is
	port (
			power_on : in std_logic;
			ok_status : out std_logic;
			fault_status : out std_logic;
			debug_port : out std_logic_vector(31 downto 0);
			clock : in std_logic
			);
end top_level;


------------------------------------------------------
------------------------------------------------------

architecture Behavioral of top_level is

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
-- Multiplier Faulty
------------------------------------------------------
component multiplier_faulty is
	port (
    clk : in std_logic;
    a : in std_logic_vector(15 downto 0);
    b : in std_logic_vector(15 downto 0);
    p : out std_logic_vector(31 downto 0)
  );
end component;


------------------------------------------------------
-- RAM
------------------------------------------------------
component RAM_block is
  port (
    clka : in std_logic;
    ena : in std_logic;
    wea : in std_logic_vector(0 downto 0);
    addra : in std_logic_vector(15 downto 0);
    dina : in std_logic_vector(31 downto 0);
    douta : out std_logic_vector(31 downto 0)
  );
end component;


------------------------------------------------------
-- ROM
------------------------------------------------------
component ROM_golden is
  port (
    clka : in std_logic;
    ena : in std_logic;
    addra : in std_logic_vector(15 downto 0);
    douta : out std_logic_vector(31 downto 0)
  );
end component;

component ROM_stimuli is
  port (
    clka : in std_logic;
    ena : in std_logic;
    addra : in std_logic_vector(15 downto 0);
    douta : out std_logic_vector(15 downto 0)
  );
end component;


------------------------------------------------------
-- ECU
------------------------------------------------------
component ECU is
	port (
			clock: in std_logic;
			power_on : in std_logic;
			data_golden : in std_logic_vector(31 downto 0);
			data_out_ram : in std_logic_vector(31 downto 0);
			result : in std_logic_vector(31 downto 0);
			enable_golden : out std_logic;
			enable_stimuli : out std_logic;
			enable_ram : out std_logic;
			wor : out std_logic_vector(0 downto 0);
			ok_status : out std_logic;
			fault_status : out std_logic;
			debug_port : out std_logic_vector(31 downto 0);
			address_ram : out std_logic_vector(15 downto 0);
			address_rom : out std_logic_vector(15 downto 0);
			data_in_ram : out std_logic_vector(31 downto 0)
			);
end component;


------------------------------------------------------
-- Internal Signals
------------------------------------------------------
signal enable_golden, enable_stimuli, enable_ram : std_logic;
signal wor : std_logic_vector(0 downto 0); 								-- wor = "0" means read, otherwise write
signal data_golden, data_in_ram, data_out_ram, result : std_logic_vector(31 downto 0);
signal data_stimuli : std_logic_vector(15 downto 0);
signal address_rom, address_ram : std_logic_vector(15 downto 0);

begin

	ECU_0: ECU port map (clock, power_on, data_golden, data_out_ram, result, enable_golden, enable_stimuli, enable_ram, wor, 
								ok_status, fault_status, debug_port, address_ram, address_rom, data_in_ram);
	ROM_g: ROM_golden port map (clock, enable_golden, address_rom, data_golden);
	ROM_s: ROM_stimuli port map (clock, enable_stimuli, address_rom, data_stimuli);
	RAM_0: RAM_block port map(clock, enable_ram, wor, address_ram, data_in_ram, data_out_ram);
	MULT:  multiplier_faulty port map(clock, data_stimuli, data_stimuli, result);
	

end Behavioral;

