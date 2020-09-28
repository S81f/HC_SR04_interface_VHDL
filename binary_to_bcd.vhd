--------------------------------------------------------------------
-- Company: TEIS AB
-- Engineer: Saif Saadaldin
--
-- Create Date: 	 2020-05-30
-- Design Name: 	 binary_to_bcd
-- Target Devices: ALTERA MAX 10. DE10-Lite board
-- Tool versions:  Quartus Price Version 18.1.0
-- Testbench file: top_vhdl
-- Do file: 		 wave.do
--
-- Description: 	The project will display the measured distance in cm on three seven segments.
--					To achieve that the distance outputs vector from component measurement_cal which is std_logic_vector(13 downto 0)
--					must be divide into three separate digits.
--					This module will convert the std_logic_vector(13 downto 0) from measurement_cal to three variables each of std_logic_vector(3 downto 0).
--					This will make easy to handle each digit and decide on which one of the three seven segments it’ll be displayed. 
--				 	The code was capied from https://en.wikipedia.org/wiki/Double_dabble and modified to works on this project
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity binary_to_bcd is
    Port (	
			--input ports  
			i_Clock		:	in std_logic;
			i_Reset_n		:	in std_logic;
			i_Binary		: 	in std_logic_vector (13 downto 0);
			i_DV_n			:	in std_logic;
			--output ports
            o_Ones 			:	out std_logic_vector (3 downto 0);
            o_Tens 			:	out std_logic_vector (3 downto 0);
            o_Hundreds		:	out std_logic_vector (3 downto 0);
			o_DV_n			:	out std_logic
          );
end binary_to_bcd;

architecture Behavioral of binary_to_bcd is


-- Build an enumerated type for the statemachines
type state_type is (idle, copying_info, counting);
-- Register to hold the current state

--ska det uppdateras?
signal state: state_type;

signal bcd_signal	:	unsigned (11 downto 0);

 

begin

	double_dabble: process(i_Clock,i_Reset_n)


		--temporary variables
		variable temp	: std_logic_vector (13 downto 0);
		variable bcd	: unsigned (11 downto 0);

	  
	  
		begin
	  
			if i_Reset_n = '0' then
					temp 				:=	(others => '0');
					bcd 				:=	(others => '0');
					bcd_signal 		<=	(others => '0');
					state 			<= idle;
		  
			elsif rising_edge(i_Clock) then
			
				case state is
				
					when idle =>
						temp 				:=	(others => '0');
						bcd 				:=	(others => '0');
						bcd_signal 		<=	(others => '0');
				 
				 -- read input into temp variable
						if i_DV_n = '0' then
							state <= copying_info;
						else
							state <= idle;
						end if;
					
					when copying_info =>
							temp :=i_Binary;
							state <= counting;
							
				 	when counting =>
						
						 -- cycle 12 times as we have 12 input bits
						 -- this could be optimized, we do not need to check and add 3 for the 
						 -- first 3 iterations as the number can never be >4
						 for i in 0 to 13 loop
						 
							if bcd(3 downto 0) > 4 then 
							  bcd(3 downto 0) := bcd(3 downto 0) + 3;
							end if;
							
							if bcd(7 downto 4) > 4 then 
							  bcd(7 downto 4) := bcd(7 downto 4) + 3;
							end if;
						 
							if bcd(11 downto 8) > 4 then
							  bcd(11 downto 8) := bcd(11 downto 8) + 3;
							end if;
						 
						 
							-- shift bcd left by 1 bit, copy MSB of temp into LSB of bcd
							bcd := bcd(10 downto 0) & temp(13); --& = Concatenation Operator not "and"
						 
							-- shift temp left by 1 bit
							temp := temp(12 downto 0) & '0';
						 
						 end loop;
						 
						 bcd_signal <= bcd;
						 state <= idle;
						 
				end case;
					 
					 
			end if;
	  
		end process double_dabble;
		
	o_DV_n <= '0' when state = counting else '1';
	-- set outputs
	o_Ones			<= std_logic_vector(bcd_signal(3 downto 0));
	o_Tens			<= std_logic_vector(bcd_signal(7 downto 4));
	o_Hundreds		<= std_logic_vector(bcd_signal(11 downto 8));
  
end Behavioral;

