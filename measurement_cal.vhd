--------------------------------------------------------------------
-- Company: TEIS AB
-- Engineer: Saif Saadaldin
--
-- Create Date: 	 2020-05-30
-- Design Name: 	 measurement_cal
-- Target Devices: ALTERA MAX 10. DE10-Lite board
-- Tool versions:  Quartus Price Version 18.1.0
-- Testbench file: top_vhdl
-- Do file: 		 wave.do
--
-- Description: 	This component will calculate the distance(in cm) to an obsticle. The component will get the number of clock cycel when the echo
--					signal was higt to the countercomponent. Every ns = 3.4*10^-4 mm. For exemple if we get 14750 from counter and multiply it with 0.00034
--					then we'll get the distance to an obsticle. We have then to divide the distance by two to get one way distance.
--					I tested with many division_cons until i found the one that gave me best results, which is 2^45/(1000*58)
---------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity measurement_cal is
		
		generic
		(
			
			ns_cycel			:	unsigned(4 downto 0)		:= to_unsigned(20,5);
			--division_cons	:	unsigned(14 downto 0) := to_unsigned(18512, 15)--2^30/(1000*58). The 1000 to convert ns to us. divide by 58 to get distance in cm.
			--division_cons	:	unsigned(19 downto 0) := to_unsigned(592409, 20)--2^35/(1000*58). The 1000 to convert ns to us. divide by 58 to get distance in cm.
			--division_cons	:	unsigned(24 downto 0) := to_unsigned(18957097, 25)--2^40/(1000*58). The 1000 to convert ns to us. divide by 58 to get distance in cm.
			division_cons	:	unsigned(29 downto 0) := to_unsigned(606627105, 30)--2^45/(1000*58)
		);
		

		port
		(
			-- Input ports
			i_Clock					:	in 	std_logic;
			i_Reset_n				:	in 	std_logic;
			i_Echo_pulse_time		:	in	std_logic_Vector(23 downto 0);--nr clock cycel on high echo pulse from counter component
			i_DV_n					:	in	std_logic;
	
			-- Output ports
			o_Distance				:	out	std_logic_Vector(13 downto 0);
			o_DV_n					:	out	std_logic
		);

end measurement_cal;



architecture Behavioral of measurement_cal is

-- Build an enumerated type for the statemachine
type state_type is (idle, counting);
-- Register to hold the current state
signal state: state_type;

signal result		:	unsigned(13 downto 0);--denna kan man effektivisera bort

constant c_ns_cycle : integer := 20;

begin

	process(i_Clock, i_Reset_n)
		
		--(i_Echo_pulse_time+ns_cycel)-1
		variable time_ns				:	unsigned(28 downto 0);
		--(time_ns+division_cons)-1
		variable	val_in_const_val	:	unsigned(58 downto 0);
	
		
	begin
		
			if i_Reset_n = '0' then
				val_in_const_val :=(others => '0');
				time_ns :=(others => '0');
				result <=(others => '0');
				state <= idle;
				
			elsif(rising_edge(i_Clock)) then
			
				case state is
					
					when idle =>
					
						val_in_const_val :=(others => '0');
						time_ns :=(others => '0');
						result <=(others => '0');
						
						if i_DV_n = '0' then
							state <= counting;
						else
							state <= idle;
						end if;
							
					when counting =>
						
						--**************************************************
						--x << k == x multiplied by 2 to the power of k
						--x >> k == x divided by 2 to the power of k
						--https://en.wikipedia.org/wiki/Division_algorithm#Division_by_a_constant
						--https://surf-vhdl.com/how-to-divide-an-integer-by-constant-in-vhdl/?unapproved=12279&moderation-hash=3ef4270bd66f6c198a12893da7ed10b0#comment-12279
						--**************************************************
					
							
						time_ns 					:= unsigned(i_Echo_pulse_time) * ns_cycel;--convert nr of clock cycel to time in ns.
						
		
						val_in_const_val 		:= time_ns * division_cons;--to convert ns to us and divide by 58 to get distance in cm.
		
						
						result 					<= val_in_const_val(58 downto 45);--right shift by 30 to get the final distance.
						
						
						state <= idle;

				end case;
						
			end if;
		
	end process;
	
	o_DV_n <= '0' when state = counting else '1';
	
	o_Distance 		<= std_logic_Vector(result);


end Behavioral;