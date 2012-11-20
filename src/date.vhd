-- Project: Uhrenbaustein
-- Module: Date
-- Author: Tobias Fülle
-- Date:   14/11/2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;		
use work.main_pkg.all;	

entity Date is
      port(
		uni:               in  universal_signals;
--		keys:              in  keypad_signals;
		current_time:      in  time_signals;
--		keyboard_focus:    in  std_logic(3 downto 0); no need of keys and keyboard_focus here. 

		characters:        out character_array_2d(3 downto 0, 19 downto 0)

      );
end Date;

architecture Behavioral of Time_State is
	type character_array_1d is array(natural range <>) of unsigned(7 downto 0);
begin

process(uni.clk) -- idea to use variables to get the current value immediately
	variable day, month, year: character_array_1d(1 downto 0);
	variable dow : character_array_1d(2 downto 0);
begin
	if(rising_edge(uni.clk)) then

		characters(0,19 downto 0) <= "                    "; -- time is left according to display_mux
		characters(1,19 downto 0) <= "                    ";
		characters(2,19 downto 0) <= "       Date:        "; -- general char - output
		characters(3,19 downto 0) <= "    " + dow + " " + day + "/" + month + "/" + year + "    ";

 		if(uni.reset = '1') then
			day := "01";
			month  := "01";
			year  := "00";
			dow  := "Sat";
		else	
			year(1) := to_integer(current_time.hour(7 downto 4)); -- depends on current_time
			year(0) := to_integer(current_time.hour(3 downto 0));
			month(1)  := to_integer(current_time.minute(4 downto 4));
			month(0)  := to_integer(current_time.minute(3 downto 0));
			day(1)  := to_integer(current_time.second(5 downto 4));
			day(0)  := to_integer(current_time.second(3 downto 0));

			case current_time_inc.dayofweek is 
				when x"01" => dow := "Mon"; --according to time_buffer: 'Mon' should be '001'
				when x"02" => dow := "Tue";
				when x"03" => dow := "Wed";
				when x"04" => dow := "Thu";
				when x"05" => dow := "Fri";
				when x"06" => dow := "Sat";
				when x"07" => dow := "Sun";
				when others => dow := "XXX";
			end case;
		end if;


	end if;
end process;

end Behavioral;
