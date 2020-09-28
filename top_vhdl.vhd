--------------------------------------------------------------------
-- Company: TEIS AB
-- Engineer: Saif Saadaldin
--
-- Create Date:  2020-05-30
-- Design Name:  HCSR04_sensor_interface
-- Target Devices: ALTERA MAX 10. DE10-Lite board
-- Tool versions:  Quartus Price Version 18.1.0
-- Testbench file: top_vhdl
-- Do file: 	wave.do
--
-- Description:	Top design file
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;



entity top_vhdl is

	port
	(
	
		-- Input ports
		i_Clock				:	in std_logic;
		i_Reset_n			:	in std_logic;
		i_Echo				:	in std_logic;-- Echo pulse back from sensor. Its one bit beacuse its only one pin.
		
		--Output ports
		o_Trigger			:	out std_logic;
		o_Sev_seg_1			:	out std_logic_vector(6 downto 0); 	-- 7-segment display (Ones)
		o_Sev_seg_2			:	out std_logic_vector(6 downto 0); 	-- 7-segment display (Tens)
		o_Sev_seg_3			:	out std_logic_vector(6 downto 0) 	-- 7-segment display (Hundreds)
	);
	
end top_vhdl;


architecture Behavioral of top_vhdl is


component HCSR04_sensor_interface

	port
	(
		-- Input ports
		i_Clock			: in std_logic;
		i_Reset_n		: in std_logic;
		i_Echo			: in std_logic;--measurement pulse from sensor. En bit eftersom det är ett pinne i sensor som skickar echo signal
		
		--Output ports
		o_Trigger		: out std_logic;
		o_Sen_interface_Ones	: out std_logic_vector(3 downto 0);
		o_Sen_interface_Tens	: out std_logic_vector(3 downto 0);
		o_Sen_interface_Hundreds	: out std_logic_vector(3 downto 0);
		o_DV_n			: out std_logic

	);
	
	end component;
	
component seven_seg_dispayer

		port
		(
		--input
		i_Clock		: in std_logic;
		i_Reset_n	: in std_logic;
		i_Sev_seg_1	: in std_logic_vector(3 downto 0); 		
		i_Sev_seg_2	: in std_logic_vector(3 downto 0); 	
		i_Sev_seg_3	: in std_logic_vector(3 downto 0); 
		i_Dv_n		: in std_logic;
		
		--output
		o_Sev_seg_1	: out std_logic_vector(6 downto 0); 	-- 7-segment display
		o_Sev_seg_2	: out std_logic_vector(6 downto 0); 	-- 7-segment display
		o_Sev_seg_3	: out std_logic_vector(6 downto 0) 	-- 7-segment displa
		);
		
	end component;
	

signal reset_n_t1,reset_n_in	: std_logic;-- for metastability

signal echo_pulse_t1,echo_pulse_t2, echo_pulse_in	: std_logic;-- for metastability

signal to_sev_display_1	: std_logic_vector(3 downto 0);
signal to_sev_display_2	: std_logic_vector(3 downto 0);
signal to_sev_display_3	: std_logic_vector(3 downto 0);

signal top_i_BCD_1	: std_logic_vector(3 downto 0);
signal top_i_BCD_2	: std_logic_vector(3 downto 0);
signal top_i_BCD_3	: std_logic_vector(3 downto 0);

signal dv_HCSR04_sev_seg	: std_logic;


begin

	reset_n_meta_stability:process(i_Clock, i_Reset_n)
	
		variable Reset_t2: std_logic;	--varibles are used in sequential VHDL inside a process. They are local inside the process and uptaded without any delay. 

		begin
			
		if rising_edge(i_Clock) then
			reset_n_t1 <= i_Reset_n;
			Reset_t2 := reset_n_t1;
			reset_n_in <= Reset_t2; 
		end if;

	end process reset_n_meta_stability;
	
	
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
	
	

	inst_HCSR04_sensor_interface : HCSR04_sensor_interface
	
		port map 
		(
		--Input ports
		i_Clock		=> i_Clock,
		i_Reset_n	=> reset_n_in,
		i_Echo		=> echo_pulse_in,
		
		--Output ports
		o_Trigger				=> o_Trigger,
		o_Sen_interface_Ones	=> to_sev_display_1,
		o_Sen_interface_Tens	=> to_sev_display_2,
		o_Sen_interface_Hundreds	=> to_sev_display_3,
		o_DV_n						=> dv_HCSR04_sev_seg

		);


	inst_seven_seg_dispayer : seven_seg_dispayer
	
		port map 
		(
			
			i_Clock		=> i_Clock,
			i_Reset_n	=> reset_n_in,
			i_Sev_seg_1	=>to_sev_display_1, 		
			i_Sev_seg_2	=>to_sev_display_2, 	
			i_Sev_seg_3	=>to_sev_display_3, 
			i_Dv_n		=>dv_HCSR04_sev_seg,
			
			o_Sev_seg_1	=>o_Sev_seg_1,
			o_Sev_seg_2	=>o_Sev_seg_2,
			o_Sev_seg_3	=>o_Sev_seg_3
		);




		

end Behavioral;


