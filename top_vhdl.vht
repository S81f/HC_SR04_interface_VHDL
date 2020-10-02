-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "07/14/2020 18:51:07"
                                                            
-- Vhdl Test Bench template for design  :  top_vhdl
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY top_vhdl_vhd_tst IS
END top_vhdl_vhd_tst;
ARCHITECTURE top_vhdl_arch OF top_vhdl_vhd_tst IS
-- constants     
constant sys_clk_period : time := 20 ns;                                                 
-- signals                                                   
SIGNAL i_Clock : STD_LOGIC :='0';
SIGNAL i_Echo : STD_LOGIC;
SIGNAL i_Reset_n : STD_LOGIC;
SIGNAL o_Sev_seg_1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL o_Sev_seg_2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL o_Sev_seg_3 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL o_Trigger : STD_LOGIC;
COMPONENT top_vhdl
	PORT (
	i_Clock : IN STD_LOGIC;
	i_Echo : IN STD_LOGIC;
	i_Reset_n : IN STD_LOGIC;
	o_Sev_seg_1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	o_Sev_seg_2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	o_Sev_seg_3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	o_Trigger : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : top_vhdl
	PORT MAP (
-- list connections between master ports and signals
	i_Clock => i_Clock,
	i_Echo => i_Echo,
	i_Reset_n => i_Reset_n,
	o_Sev_seg_1 => o_Sev_seg_1,
	o_Sev_seg_2 => o_Sev_seg_2,
	o_Sev_seg_3 => o_Sev_seg_3,
	o_Trigger => o_Trigger
	);
	
--the clock start oscillating 
i_Clock <= not i_Clock after 10 ns;-- här gör man så klockan oscillerar och perioden är 20ns
	
--reset initiation
i_Reset_n <= '0', '1' after 20 ns;


init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
     		   i_Echo <= '0';
		--***********************************************************************************************************************************************
		-- The simulation will start when o_Trigger is = 1 which gives a trigger signal to the sensoren, TTL pulse 10us. 
		--According to the sensor datasheet distance(cm)= us/58. If an obsticle is 100mm away (10cm) gives two way wave travel tiem = 580us
		--That means the i_Echo will be hight the same amount of time when the wave is detected by sensor
		--***********************************************************************************************************************************************
		
		--first trigging the senor
		-------------------------------------
		wait until o_Trigger = '1';

		---------------------------------------------------------------------------------------------
		--waiting until the wave hit an obsticle and returns to the sensor.
		--I added 10us to the numbers below to incount the 10us from the trigger
		---------------------------------------------------------------------------------------------
		wait for 590 us;-- simulate obsticle 100 mm away 10cm. 
		--wait for 11610 us;-- simulate obsticle 2000 mm away 200cm. 
		--wait for 23210 us;-- simulate obsticle 4000 mm away 400cm. 

		--------------------------------------------------------------------------------------------------------------
		--the wave hits the sensor and the i_Echo goes high the same amount of time
		-------------------------------------------------------------------------------------------------------------
		i_Echo <= '1';
		wait for 580 us;--10cm
		--wait for 11600 us;--200cm
		--wait for 23200 us;--400cm

		---------------------------------------------------------------------------
		--the i_Echo goes down and the measurement starts
		---------------------------------------------------------------------------
		i_Echo <= '0';    

        
WAIT;                                                       
END PROCESS init;                                           
                                         
END top_vhdl_arch;
