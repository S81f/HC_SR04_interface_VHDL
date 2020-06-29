--------------------------------------------------------------------
-- Company: TEIS AB
-- Engineer: Saif Saadaldin
--
-- Create Date: 	 2020-05-30
-- Design Name: 	 HCSR04_sensor_interface
-- Target Devices: ALTERA MAX 10. DE10-Lite board
-- Tool versions:  Quartus Price Version 18.1.0
-- Testbench file: HCSR04_sensor_interface_vhd_tst.vht
-- Do file: 		 
--
-- Description: This component will count the time the echo signal (echo_in pin) is high. The time
--		will be send in microseconds (us) to another component to measure the distance to an obsticle.
--					 
--					 
--
-- In_signals:
-- 		clk_50		:	in	std_logic; (50 MHz)
--			reset_n		:	in	std_logic;	(Active low)
--			echo_in		:	in	std_logic;
--
--
--
-- Out_signals:
--		dv_n				:	out	std_logic; 	data valide (dv) will be high when sending pulse_time to other component.
--										In this way the next component will know that pulse_time value is right
--
--		pulse_time		:	out	std_logic_vector (23 downto 0);


-------------------------------------------------------------------


--**************************************************************************************************************************************'
-- if any obsticle is 400 cm away from sensor then it'll take the ultrasonic wave 1/850 sec to hit the obsticle.
-- and then another 1/850 sec to travel back to the sensor. So the max time the echo_in pulse needed to be high is equal 
-- to the total time it takes the ultrasonic wave to travel back and its 1/425 sec (1/850 + 1/850).
-- 1/425 sec give us 23529411.76 ns = approx 23,530,000.
--	To count that in FPGA with 50MHz clock-->20ns clock cycle = 25530000/20ns = 1176500 clock cycle is the nr of clock cycle when the eco is higt
-- Thats why we need a std_logic_vector 23 downto 0 to our echo_pulse_counter 
--*******************************************************************************************************************************************

 
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is

		port
		(
			-- Input ports
			clk_50		:	in	std_logic;
			reset_n		:	in std_logic;
			--echo_pulse	:	in	std_logic_vector (27 downto 0);
			echo_in		:	in	std_logic;
			
			-- Output ports
			dv_n		:	out	std_logic;
			pulse_time	:	out	std_logic_vector (23 downto 0)--kan de inte vara unsigned (27 downto 0)? jag fick fel när jag gjorde det!
		);
end counter;



architecture Behavioral of counter is

signal reset_n_t1,reset_n_in				: std_logic;-- for metastability

signal echo_pulse_t1,echo_pulse_t2, echo_pulse_in	: std_logic;-- for metastability

signal echo_pulse_counter				: unsigned (23 downto 0);



-- Build an enumerated type for the statemachine
type state_type is (idle, counting, sending_info);
-- Register to hold the current state
signal state: state_type;



begin

--***************************************************************************************************************************
	reset_n_meta_stability:process(clk_50, reset_n)
	
	
		variable Reset_t2: std_logic;	--	variablar används för sekventiell exekvering. Variabel värde uppdatera på en gång, 
												--	ingen delay till skillnad från signaler
												--	variablar har lokal scope, inuti en process. Signalar har architecture scope
			begin
			
				if rising_edge(clk_50) then
					reset_n_t1 <= reset_n;
					Reset_t2 := reset_n_t1;--värdet på Reset_t2 uppdateras direkt
					reset_n_in <= Reset_t2; 
				end if;
				
	end process reset_n_meta_stability;
	
--***************************************************************************************************************************


--***************************************************************************************************************************
	
	echo_pulse_meta_stability:process(clk_50, echo_in)
	-- vad skiljer denna metastability process mot den ovan?

			begin
			
				if reset_n_in = '0' then
					echo_pulse_t1 <= '0';
					echo_pulse_t2 <= '0';
					echo_pulse_in <= '0';
				elsif rising_edge(clk_50) then
					echo_pulse_t1 <= echo_in;
					echo_pulse_t2 <= echo_pulse_t1;
					echo_pulse_in <= echo_pulse_t2;
				end if;
				
	end process echo_pulse_meta_stability;

--***************************************************************************************************************************


measuring_echo_pulse_time: process (clk_50,reset_n_in)
begin

	if (reset_n_in = '0') then
		
		state <= idle;
		dv_n <= '1';--wont send data
		

	elsif (rising_edge(clk_50)) then 
		
		case state is
				
				when idle =>-- out of range (no echo
				
					echo_pulse_counter <= (others => '0');
					dv_n <= '1';--wont send data
					
					if(echo_pulse_in = '1') then
						state <= counting;
					else
						state <= idle; 	-- if there's no echo stay in idle or obsticle below 2cm (58823.52941ns)in distance
					end if;
					
					
				when counting =>
					
					echo_pulse_counter <= echo_pulse_counter + 1;--every +1 gives 20 ns
								
					
					if(echo_pulse_in = '1') then
						state <= counting;
					else
						state <= sending_info;

					end if;
					
				--when conv_to_us =>
					--vi kanske kan ha en tillstånd som omvandlar till us innan vi skickar till measuremeant component
				
					
				when sending_info =>
					
					dv_n <= '0';
					pulse_time <= std_logic_vector(echo_pulse_counter);
					
					if(echo_pulse_in = '1') then
						state <= counting;
					else
						state <= idle;
					end if;
				
				--when out_of_range =>
			
			
				--when no_pos_change =>
			
		end case;
		
		
		
	end if;
end process measuring_echo_pulse_time;


end Behavioral;
