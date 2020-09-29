--------------------------------------------------------------------
-- Company: TEIS AB
-- Engineer: Saif Saadaldin
--
-- Create Date: 	 2020-05-30
-- Design Name: 	 HCSR04_sensor_interface
-- Target Devices: ALTERA MAX 10. DE10-Lite board
-- Tool versions:  Quartus Price Version 18.1.0
-- Testbench file: top_vhdl
-- Do file: 		 wave.do
--
-- Description:	Send a 10us trigger pulse to HCSRo4 sensor to activate the sensors distance measurement

-- improvments:
--***********************
--Pulse generating can be done by integer, then it'll maybe easier to understand the code. Se teori 5b vhdl 1.
--***********************
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity trigger_generator is

	port
	(

		-- Input ports
		i_Clock				: in std_logic;
		i_Reset_n			: in std_logic;

		-- Output ports
		o_Trigger			: out std_logic	--one bit beacuse its only one input pin on the sensore side.
	);
end trigger_generator;



architecture Behavioral of trigger_generator is


signal counter 	: unsigned (23 downto 0) := "000000000000000000000000";-- counts up to 60ms


begin

process(i_Clock,i_Reset_n)

	begin

		if i_Reset_n = '0' then
			counter <= (others => '0');

		elsif rising_edge(i_Clock) then
			if(counter >= 3000000) then--3000000 = 60ms. According to sensor datasheet it must by at least 60ms between each trigger signal 
				counter <= (others => '0');
			else
				counter <= counter + 1;
			end if;
		end if;


end process;



o_Trigger <= '1' when counter >= 1 and counter <= 500 else '0';-- 10uS trigger signal

end Behavioral;

