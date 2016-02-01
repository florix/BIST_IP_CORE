------------------------------------------------------
-- Assignment SSDS, Andrea Floridia S224906
-- ECU
------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


------------------------------------------------------
------------------------------------------------------

entity ECU is
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
end ECU;


------------------------------------------------------
------------------------------------------------------


architecture Behavioral of ECU is

------------------------------------------------------
-- Counter
------------------------------------------------------
component down_counter is
port (
			I: in std_logic_vector(15 downto 0);
			tc: out std_logic;
			clk, clr, cnt: in std_logic 
		);
end component;


------------------------------------------------------
-- Control Unit
------------------------------------------------------
component CU is
port (
			clock: in std_logic;
			power_on : in std_logic;
			data_golden : in std_logic_vector(31 downto 0);
			command : out std_logic_vector(1 downto 0);
			result : in std_logic_vector(31 downto 0);
			enable_golden : out std_logic;
			enable_stimuli : out std_logic;
			enable_ram : out std_logic;
			wor : out std_logic_vector(0 downto 0);
			ok_status : out std_logic;
			fault_status : out std_logic;
			debug_data : out std_logic_vector(15 downto 0);
			address_ram : out std_logic_vector(15 downto 0);
			address_rom : out std_logic_vector(15 downto 0);
			data_in_ram : out std_logic_vector(31 downto 0);
			clear_counter : out std_logic;
			count : out std_logic;
			tc : in std_logic;
			in_counter : out std_logic_vector(15 downto 0)
			);
end component;


------------------------------------------------------
-- Debug Interface
------------------------------------------------------
component debug_interface is
port (
		command : in std_logic_vector(1 downto 0);
		number_of_errors : in std_logic_vector(15 downto 0);
		data_out_ram : in std_logic_vector(31 downto 0);
		debug_port : out std_logic_vector(31 downto 0)
		);
end component;


------------------------------------------------------
-- Internal Signals
------------------------------------------------------
signal clear_counter, count, tc : std_logic;
signal in_counter : std_logic_vector(15 downto 0);
signal debug_data : std_logic_vector(15 downto 0);
signal command : std_logic_vector(1 downto 0);

begin


	
	CU_0: CU port map (	clock, power_on, data_golden, command, result, enable_golden, enable_stimuli,
								enable_ram, wor, ok_status, fault_status, debug_data, address_ram, address_rom,
								data_in_ram, clear_counter, count, tc, in_counter);
	CNT0: down_counter port map(in_counter, tc, clock, clear_counter, count);
	DB_0: debug_interface port map(command, debug_data, data_out_ram, debug_port);
	
end Behavioral;

