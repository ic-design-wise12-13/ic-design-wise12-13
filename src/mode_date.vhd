-- Project: Uhrenbaustein
-- Module: Date
-- Author: Tobias Fülle
-- Date:   14/11/2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;		
use work.main_pkg.all;	

entity mode_date is
      port(
		uni:               in  universal_signals;
		current_time:      in  time_signals;
		
		characters:        out character_array_2d(3 downto 0, 19 downto 0)
      );
end Date;

architecture behavioral of mode_date is

	signal char : string(1 to 80);
	signal dow, ndow : string(1 to 3);
	signal day1, day2, mon1, mon2, year1, year2 : unsigned(7 downto 0);
	
	

begin

-- constant assignment of character output:
char(1 to 80) <= "                                               Date:                    " & '/' & "  " & '/' & "    ";

process(char, ndow, day1,day2,mon1,mon2,year1,year2)
begin
		for row in 0 to 3 loop
			for col in 0 to 19 loop
				if(row = 3 AND col = 4) then
					characters(row,col) <= to_unsigned(character'pos(ndow(1)),8); --character'val(to_integer(characters_out(row, col)))
				elsif(row = 3 AND col = 5) then					
					characters(row,col) <= to_unsigned(character'pos(ndow(2)),8);
				elsif(row = 3 AND col = 6) then					
					characters(row,col) <= to_unsigned(character'pos(ndow(3)),8);
				elsif(row = 3 AND col = 8) then					
					characters(row,col) <= day1;
				elsif(row = 3 AND col = 9) then					
					characters(row,col) <= day2;
				elsif(row = 3 AND col = 11) then					
					characters(row,col) <= mon1;
				elsif(row = 3 AND col = 12) then					
					characters(row,col) <= mon2;
				elsif(row = 3 AND col = 14) then					
					characters(row,col) <= year1;
				elsif(row = 3 AND col = 15) then					
					characters(row,col) <= year2;
				else
					characters(row, col) <= to_unsigned(character'pos(char(20*row + col + 1)), 8);
				end if;
			end loop;
		end loop;
end process;

process(uni.clk)
begin

	if(rising_edge(uni.clk)) then
	
 		if(uni.reset = '1') then
			ndow <= "Sat";
			day1 <= to_unsigned(0,8);
			day2 <= to_unsigned(1,8);			
			mon1 <= to_unsigned(0,8);
			mon2 <= to_unsigned(1,8);
			year1 <= to_unsigned(0,8);
			year2 <= to_unsigned(0,8);
		else	
			ndow <= dow;
			day1 <= "000000" & current_time.day(5 downto 4);
			day2 <= "0000" & current_time.day(3 downto 0);
			mon1 <= "0000000" & current_time.month(4);					
			mon2 <= "0000" & current_time.month(3 downto 0);			
			year1 <= "0000" & current_time.year(7 downto 4);
			year2 <= "0000" & current_time.year(3 downto 0);
		end if;
	end if;
end process;

	
--get names from dayofweek signal
process(current_time.dayofweek)
begin
	case current_time.dayofweek is 
		when "001" => dow <= "Mon"; --according to time_buffer: 'Mon' should be '001'
		when "010" => dow <= "Tue";
		when "011" => dow <= "Wed";
		when "100" => dow <= "Thu";
		when "101" => dow <= "Fri";
		when "110" => dow <= "Sat";
		when "111" => dow <= "Sun";
		when others => dow <= "XXX";
	end case;
end process;	

end Behavioral;
