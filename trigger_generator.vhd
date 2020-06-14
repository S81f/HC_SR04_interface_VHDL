--------------------------------------------------------------------
-- Company: TEIS AB
-- Engineer: Saif Saadaldin
--
-- Create Date: 	 2020-05-30
-- Design Name: 	 HCSR04_sensor_interface
-- Target Devices: ALTERA MAX 10. DE10-Lite board
-- Tool versions:  Quartus Price Version 18.1.0
-- Testbench file: trigger_test.vht
-- Do file: 		 trigger_test_run_msim_rtl_vhdl_saif.do
--
-- Description:	Send a 10us trigger pulse to HCSRo4 sensor to activate the sensors distance measurement
--
-- In_signals:
-- 		clk_50		:	in	std_logic; (50 MHz)
--			reset_n		:	in	std_logic;	(Active low)
--
-- Out_signals:
-- 	trigger_pulse	:	out	std_logic; (10 us pulse)


-------------------------------------------------------------------


--************************************
--	det går att göra pulse genarating mha integer om det är enklare att förstå, se teori 5b vhdl 1
--*************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity trigger_generator is

		port
		(
			-- Input ports
			clk_50		:	in	std_logic;
			reset_n		:	in	std_logic;
	
			-- Output ports
			trigger_pulse	:	out	std_logic--one bit beacuse its only one input pin on the sensore side.
		);
end trigger_generator;



architecture Behavioral of trigger_generator is


--signal counter	: unsigned (9 downto 0);
--signal active_counter	:	unsigned(8 downto 0) := "000000000";
signal counter 	: unsigned (23 downto 0) := "000000000000000000000000";-- räknar upp till 60ms


begin

process(clk_50)

	begin
	
		if reset_n = '0' then
			-- clear counter 
			counter <= (others => '0');
			-- bör inte trigger_pulse var stabil i några ns efter en omstart?
			--trigger_pulse <= (others => '0');--kan man göra så?
			
			--det kan bli bättre lösning om vi kan stoppa och nolla counter när en echo fås tillbaka.
			--kanske går att göra  om man delar kodnigen i tillståndsmaskiner som i counter fallet
		elsif rising_edge(clk_50) then
			if(counter >= 3000000) then--3000000 motsvarar 60 ms
				counter <= (others => '0');
			else
				counter <= counter + 1;
			end if;
		end if;


end process;



trigger_pulse <= '1' when counter >= 1 and counter <= 500 else '0';--under 10uS tid

--vänta 50ms eller få signal från counter på att du kan skicka trigger när inget echo finns


	-- Process Statement (optional)

	-- Concurrent Procedure Call (optional)

	-- Concurrent Signal Assignment (optional)

	-- Conditional Signal Assignment (optional)

	-- Selected Signal Assignment (optional)

	-- Component Instantiation Statement (optional)

	-- Generate Statement (optional)

end Behavioral;

