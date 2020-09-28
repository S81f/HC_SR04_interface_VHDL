--------------------------------------------------------------------
-- Company: TEIS AB
-- Engineer: Saif Saadaldin
--
-- Create Date:  2020-05-30
-- Design Name:  HCSR04_sensor_interface
-- Target Devices: ALTERA MAX 10. DE10-Lite board
-- Tool versions:  Quartus Price Version 18.1.0
-- Testbench file: top_vhdl
-- Do file: 	 wave.do
--
-- Description: This component will count the time the echo signal (echo_in pin) is high. The time
--		 will be send in microseconds (us) to another component to measure the distance to an obsticle.
--					 

---------------------------------------------------------------------------------------


--**************************************************************************************************************************************'
-- if any obsticle is 400 cm away from sensor and according to sensor datasheet then it'll take the ultrasonic wave 23200us to hit the obsticle
-- and back to the sensor. 23,200 us = 232,00,000 ns

-- To count that in FPGA with 50MHz clock-->20ns clock cycle = 23200000/20ns = 1160000 clock cycle is the nr of clock cycle when the eco is higt
-- Thats why we need a std_logic_vector 23 downto 0 to our echo_pulse_counter 
--*******************************************************************************************************************************************

 
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;--fake library

entity counter is

		port
		(
			-- input ports
			i_Clock			:	in std_logic;
			i_Reset_n		:	in std_logic;
			i_Echo			:	in std_logic;
			-- Output ports
			o_DV_n			:	out std_logic;--data valide (dv) will be high when sending pulse_time to other component.
--									In this way the next component will know that pulse_time value is right
			o_Echo_pulse_time	:	out std_logic_vector(23 downto 0)
	
		);
end counter;



architecture Behavioral of counter is

--signals has architecture scope
signal reset_n_t1,reset_n_in			: std_logic;-- for metastability

signal echo_pulse_t1,echo_pulse_t2, echo_pulse_in	: std_logic;-- for metastability

signal echo_pulse_counter				: unsigned (23 downto 0);



-- Build an enumerated type for the statemachine
type state_type is (idle, counting, sending_info);
-- Register to hold the current state
signal state: state_type;



begin

--***************************************************************************************************************************
	
--********************************************************************************************
--It maybe useful to test reading input signal without meta stability to see what the results are
--**********************************************************************************************
	-- reset_n_meta_stability:process(i_Clock, i_Reset_n)
	
	
		-- variable Reset_t2: std_logic;	--varibles are used in sequential VHDL inside a process. They are local inside the process and uptaded without any delay. 
								
			-- begin
			
				-- if rising_edge(i_Clock) then
					-- reset_n_t1 <= i_Reset_n;
					-- Reset_t2 := reset_n_t1;
					-- reset_n_in <= Reset_t2; 
				-- end if;
				
	-- end process reset_n_meta_stability;
	
--***************************************************************************************************************************


--***************************************************************************************************************************
	
	echo_pulse_meta_stability:process(i_Clock, i_Echo,reset_n_in)
			begin
			
				if reset_n_in = '0' then
					echo_pulse_t1 <= '0';
					echo_pulse_t2 <= '0';
					echo_pulse_in <= '0';
				elsif rising_edge(i_Clock) then
					echo_pulse_t1 <= i_Echo;
					echo_pulse_t2 <= echo_pulse_t1;
					echo_pulse_in <= echo_pulse_t2;
				end if;
				
	end process echo_pulse_meta_stability;

--***************************************************************************************************************************


measuring_echo_pulse_time: process (i_Clock,reset_n_in)

	begin
	
		if (reset_n_in = '0') then
			o_Echo_pulse_time <= (others => '0');
			echo_pulse_counter <= (others => '0');
			state <= idle;
			o_DV_n <= '1';--wont send data
			
	
		elsif (rising_edge(i_Clock)) then
			
			case state is
					
					when idle => --out of range (no echo)
					
						echo_pulse_counter <= (others => '0');
						o_DV_n <= '1';--wont send data
						
						if(echo_pulse_in = '1') then
							state <= counting;
						else
							state <= idle; 	-- if there's no echo stay in idle or obsticle below 2cm (58823.52941ns)in distance
						end if;
						
						
					when counting =>
						
						echo_pulse_counter <= echo_pulse_counter + 1;--increases with 20ns every time									
						
						if(echo_pulse_in = '1') then
							state <= counting;
						else
							state <= sending_info;
						end if;
									
						
					when sending_info =>
						
						o_DV_n <= '0';
						o_Echo_pulse_time <= std_logic_vector(echo_pulse_counter);
						
						if(echo_pulse_in = '1') then
							state <= counting;--echo_pulse_counter måste nollställas nånstans ju?
						else
							state <= idle;
						end if;
					
					--when out_of_range =>
						--maybe in future one can add these state
				
					--when no_pos_change =>
						--maybe in future one can add these state
			end case;
			
		end if;
	end process measuring_echo_pulse_time;


end Behavioral;
