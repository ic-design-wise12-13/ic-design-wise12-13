-- Project: Uhrenbaustein
-- Module: Time_State
-- Author: Tobias Fülle
-- Date:   14/11/2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;		
use work.main_pkg.all;	
--use ieee.std_unsigned.all

entity Time_State is
      port(
		uni:               in  universal_signals;
--		keys:              in  keypad_signals;
		current_time:      in  time_signals;
--		keyboard_focus:    in  std_logic (3 downto 0);  no need of keys and keyboard_focus

		characters:        out character_array_2d(3 downto 0, 19 downto 0)

      );
end Time_State;

architecture Behavioral of Time_State is
	type character_array_1d is array(natural range <>) of unsigned(7 downto 0);
begin


process(uni.clk) -- idea to declare variables in the process to get the current value immediately
	variable sec, min, hour: character_array_1d(1 downto 0);
	variable DCL : character_array_1d(2 downto 0);
begin
	if(rising_edge(uni.clk)) then

		characters(0,19 downto 0) <= "       Time:        ";  --general output from that module
		characters(1,19 downto 0) <= "A    " + hour + ":" + min + ":" + sec + "  " + DCL + " S";
		characters(2,19 downto 0) <= "                    ";
		characters(3,19 downto 0) <= "                    ";

 		if(uni.reset = '1') then --reset-State: 00:00:00
			hour := "00";
			min  := "00";
			sec  := "00";
			DCL  := "   ";
		else	   -- get the integer value from the 'to_integer' function
			hour(1) := to_integer(current_time.hour(5 downto 4)); 
			hour(0) := to_integer(current_time.hour(3 downto 0));
			min(1)  := to_integer(current_time.minute(6 downto 4));
			min(0)  := to_integer(current_time.minute(3 downto 0));
			sec(1)  := to_integer(current_time.second(6 downto 4));
			sec(0)  := to_integer(current_time.second(3 downto 0));
			if (current_time.valid = '1') then  -- decide, if the signal is valid or not. 
				DCL := "DCF";
			else
				DCL := "   ";
			end if;	
		end if;


	end if;
end process;

end Behavioral;
