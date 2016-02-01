------------------------------------------------------
-- Assignment SSDS, Andrea Floridia S224906
-- Control Unit
------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

------------------------------------------------------
------------------------------------------------------

entity CU is
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
end CU;


------------------------------------------------------
------------------------------------------------------


architecture Behavioral of CU is

------------------------------------------------------
-- State Signals
------------------------------------------------------
type state is (init, s1, s2, s3, s4, s5, s6, s7, s8, IDLE);
signal current_state, next_state : state;

------------------------------------------------------
-- Debug Signals
------------------------------------------------------
signal number_of_errors : std_logic_vector(15 downto 0) := (others => '0');
signal cur_number_of_errors : std_logic_vector(15 downto 0); 					-- current signal for register, used for reading

------------------------------------------------------
-- Internal Signal
------------------------------------------------------
signal int_address_ram, int_address_rom : std_logic_vector(15 downto 0);
signal cur_address_ram, cur_address_rom : std_logic_vector(15 downto 0); 	-- current signal for register, used for reading

begin


	CU_State_Reg:process (clock, power_on)
	begin
		if (power_on = '1') then
			current_state <= init;
		elsif (clock = '1' and clock'event) then
			current_state <= next_state;
			cur_address_ram <= int_address_ram; 			-- update the registers for other variables
			cur_address_rom <= int_address_rom; 
			cur_number_of_errors <= number_of_errors; 
		end if;
	end process;
	

	CU_Comb_Logic:process (current_state, data_golden, result, tc, cur_address_ram, cur_address_rom, cur_number_of_errors)
	constant EXIT_ADDRESS : integer := 9999;
	begin
		case current_state is
			when init =>
				int_address_ram <= (others => '0');
				int_address_rom <= (others => '0');	
				enable_golden <= '0';		
				enable_stimuli <= '0';
				enable_ram <= '0';
				wor <= "0";
				clear_counter <= '1';
				count <= '0';
				in_counter <= conv_std_logic_vector(1, 16);
				command <= "00"; 
				ok_status <= 'Z';							
				fault_status <= 'Z';						
				next_state <= s1;
			
			when s1 =>
				enable_golden <= '1';
				enable_stimuli <= '1';
			   if (tc = '1') then	-- wait  more due to ROM latency + Multiplier for 1st pattern
					count <= '0';		-- stop the timer but not reset to avoid tc = '0. So can use tc = '1' for transition to s2	
					next_state <= s2;
				else
					count <= '1';		
					clear_counter <= '0';  
					next_state <= s1;
				end if;
			
			
				
			when s2 => 
				if (data_golden /= result) then
					-- store the wrong value
					wor <= "1";
					enable_ram <= '1';
					data_in_ram <= result;
					next_state <= s3; 
				else
					next_state <= s3;
				end if;
				
			when s3 =>
				if ((cur_address_rom = conv_std_logic_vector(EXIT_ADDRESS,16)) and ((data_golden /= result)) and (cur_number_of_errors = "0000000000000000")) then
					number_of_errors <= cur_number_of_errors + 1;
					wor <= "0";
					enable_ram <= '0';
					clear_counter <= '1';
					in_counter <= conv_std_logic_vector(7507, 16);
					next_state <= s4;
				elsif ((cur_address_rom = conv_std_logic_vector(EXIT_ADDRESS,16)) and ((data_golden /= result)) and (not(cur_number_of_errors = "0000000000000000"))) then
					number_of_errors <= cur_number_of_errors + 1;
					wor <= "0";
					enable_ram <= '0';
					clear_counter <= '1';
					in_counter <= conv_std_logic_vector(150, 16);
					next_state <= s4;
				elsif ((cur_address_rom = conv_std_logic_vector(EXIT_ADDRESS,16)) and (not(data_golden /= result)) and (cur_number_of_errors = "0000000000000000")) then
					wor <= "0";
					enable_ram <= '0';
					clear_counter <= '1';
					in_counter <= conv_std_logic_vector(7507, 16);
					next_state <= s4;
				elsif ((cur_address_rom = conv_std_logic_vector(EXIT_ADDRESS,16)) and (not(data_golden /= result)) and (not(cur_number_of_errors = "0000000000000000"))) then
					wor <= "0";
					enable_ram <= '0';
					clear_counter <= '1';
					in_counter <= conv_std_logic_vector(150, 16);
					next_state <= s4;
				elsif ((not(cur_address_rom = conv_std_logic_vector(EXIT_ADDRESS,16))) and ((data_golden /= result))) then
					number_of_errors <= cur_number_of_errors + 1;
					int_address_ram <= cur_address_ram + "0000000000000001";
					int_address_rom <= cur_address_rom + "0000000000000001";
					next_state <= s1;
				elsif ((not(cur_address_rom = conv_std_logic_vector(EXIT_ADDRESS,16))) and (not(data_golden /= result))) then
					int_address_rom <= cur_address_rom + "0000000000000001";
					next_state <= s1;
				else
					next_state <= IDLE;
				end if;
				
				
			when s4 =>
				clear_counter <= '0';
				count <= '1';
				if( cur_number_of_errors = "0000000000000000") then
					-- ok_status
					ok_status <= '1';
					next_state <= s5;
				else 
					--fault status, start reading from RAM here so fault results are available when needed
					fault_status <= '1';
					command <= "10";
					int_address_ram <= (others => '0');
					wor <= "0";
					enable_ram <= '1';
					next_state <= s6;
				end if;
						
					
			when s5 =>
				if (tc = '1') then
					count <= '0';
					next_state <= IDLE;
				else
					next_state <= s5;
				end if;
				
			when s6 =>
				if (tc = '1') then
					count <= '0';
					next_state <= s7;
				else
					next_state <= s6;
				end if;
				
			when s7 =>
				if (cur_address_ram = cur_number_of_errors) then
						fault_status <= '0';
						command <= "00";
						next_state <= IDLE;
						
				else
						command <= "01"; 
						next_state <= s8;
				end if;
					
			when s8 =>
				int_address_ram <= cur_address_ram + "0000000000000001";
				next_state <= s7;
				
			when IDLE =>
				if (cur_number_of_errors = "0000000000000000") then
					ok_status <= '0';
					next_state <= IDLE;
				else
					next_state <= IDLE;
				end if;
				
				
			when others => 			-- Recover in case of errors
				next_state <= init;
			end case;
				
	end process;


	debug_data <= number_of_errors;
	address_ram <= int_address_ram;
	address_rom <= int_address_rom;
	
end Behavioral;

