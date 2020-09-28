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
-- Description:	Top design file for the sensor interface
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;



entity HCSR04_sensor_interface is

	port
	(
	
		-- Input ports
		i_Clock				:	in 	std_logic;
		i_Reset_n			:	in 	std_logic;
		i_Echo				:	in	std_logic;
		
		--Output ports
		o_Trigger					:	out	std_logic;
		o_Sen_interface_Ones		:	out std_logic_vector(3 downto 0);
		o_Sen_interface_Tens		:	out std_logic_vector(3 downto 0);
		o_Sen_interface_Hundreds	:	out std_logic_vector(3 downto 0);
		o_DV_n						:	out std_logic

	);
	
end HCSR04_sensor_interface;


architecture Behavioral of HCSR04_sensor_interface is

	component counter
	
		port
		(
			-- Input ports
			i_Clock					:	in std_logic;
			i_Reset_n				:	in std_logic;
			i_Echo					:	in std_logic;
	
			-- Output ports
			o_DV_n					:	out	std_logic;
			o_Echo_pulse_time		:	out	std_logic_vector(23 downto 0)
		);
	
	end component;
	
	

	component trigger_generator
	
		port
		(
			-- Input ports
			i_Clock				:	in std_logic;
			i_Reset_n			:	in std_logic;
	
			-- Output ports
			o_Trigger			:	out	std_logic
		);
	
	end component;


	component measurement_cal
	
		port
		(
			-- Input ports
			i_Clock					:	in std_logic;
			i_Reset_n				:	in std_logic;
			i_Echo_pulse_time		:	in std_logic_Vector(23 downto 0);--measurement pulse from sensor
			i_DV_n					:	in std_logic;
	
			-- Output ports
			o_Distance			:	out	std_logic_Vector(13 downto 0);
			o_DV_n				:	out	std_logic
		);
	
	end component;
	
	component binary_to_bcd --Binary Coded Decimal 
	
		port
		(
			i_Clock			: in std_logic;
			i_Reset_n		: in std_logic;
			i_Binary		: in std_logic_vector (13 downto 0);
			i_DV_n			: in std_logic;
				
            o_Ones 			: out std_logic_vector (3 downto 0);
            o_Tens 			: out std_logic_vector (3 downto 0);
            o_Hundreds 		: out std_logic_vector (3 downto 0);
			o_DV_n			: out std_logic
           
		);
	
	end component;

signal	measured_distance 				: std_logic_vector(13 downto 0);
signal	echo_time_length				: std_logic_vector(23 downto 0);
signal	data_valid_counter_meas			: std_logic;
signal	data_valid_meas_binarybcd		: std_logic;


	

begin

	inst_counter : counter
	
		port map 
		(
			i_Clock 			=> i_Clock,
			i_Reset_n 			=> i_Reset_n,
			i_Echo 				=> i_Echo,
			o_DV_n				=> data_valid_counter_meas,
			o_Echo_pulse_time	=> echo_time_length
		);
		
		

	inst_trigger_generator : trigger_generator
	
		port map 
		(
			i_Clock 		=> i_Clock,
			i_Reset_n 		=> i_Reset_n,
			o_Trigger 		=> o_Trigger
		);


	inst_measurement_cal : measurement_cal

		port map 
		(
			i_Clock 			=> i_Clock,
			i_Reset_n 			=> i_Reset_n,
			i_Echo_pulse_time 	=> echo_time_length,
			i_DV_n				=> data_valid_counter_meas,
			o_Distance			=> measured_distance,
			o_DV_n		=> data_valid_meas_binarybcd
			
		);
		
	
	inst_binary_to_bcd : binary_to_bcd
	
		port map 
		(
			i_Clock				=> i_Clock,
			i_Reset_n 			=> i_Reset_n,
			i_Binary			=> measured_distance,
			i_DV_n				=> data_valid_meas_binarybcd,

			o_Ones				=> o_Sen_interface_Ones,
			o_Tens				=> o_Sen_interface_Tens,
			o_Hundreds			=> o_Sen_interface_Hundreds,
			o_DV_n				=> o_DV_n
		
		);
		

end Behavioral;


