-- Project: Uhrenbaustein
-- Module: Time_State
-- Author: Tobias Flle
-- Date: 14/11/2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;	
use work.main_pkg.all;	
--use ieee.std_unsigned.all

entity mode_time is
      port(
uni: in universal_signals;
current_time: in time_signals;

characters: out character_array_2d(3 downto 0, 19 downto 0)
      );
end mode_time;

architecture behavioral of mode_time is
signal char : string(1 to 80);
signal dcf : string(1 to 3);
signal hour1, hour2, mindelay, min1, min2, sec1, sec2 : unsigned(7 downto 0);
begin

-- constant assignment of character output:
char(1 to 80) <= "       Time:        A      " & ':' & "  " & ':' & "        S                                        ";


process(char, hour1, hour2, min1, min2, sec1, sec2, dcf)
begin
for row in 0 to 3 loop
for col in 0 to 19 loop
if(row = 1 AND col = 5) then
characters(row,col) <= hour1;
elsif(row = 1 AND col = 6) then	
characters(row,col) <= hour2;
elsif(row = 1 AND col = 8) then	
characters(row,col) <= min1;
elsif(row = 1 AND col = 9) then	
characters(row,col) <= min2;
elsif(row = 1 AND col = 11) then	
characters(row,col) <= sec1;
elsif(row = 1 AND col = 12) then	
characters(row,col) <= sec2;
elsif(row = 1 AND col = 15) then	
characters(row,col) <= to_unsigned(character'pos(dcf(1)), 8);
elsif(row = 1 AND col = 16) then	
characters(row,col) <= to_unsigned(character'pos(dcf(2)), 8);
elsif(row = 1 AND col = 17) then	
characters(row,col) <= to_unsigned(character'pos(dcf(3)), 8);
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
dcf <= "   ";
hour1 <= "0011" & to_unsigned(0,4);
hour2 <= "0011" & to_unsigned(0,4);
min1 <= "0011" & to_unsigned(0,4);
min2 <= "0011" & to_unsigned(0,4);
sec1 <= "0011" & to_unsigned(0,4);
sec2 <= "0011" & to_unsigned(0,4);
else	
if(current_time.valid = '1') then
dcf <= "DCF";
else
dcf <= "   ";
end if;
hour1 <= "001100" & current_time.hour(5 downto 4);
hour2 <= "0011" & current_time.hour(3 downto 0);
min1 <= "00110" & current_time.minute(6 downto 4);	
min2 <= "0011" & current_time.minute(3 downto 0);	
sec1 <= "00110" & current_time.second(6 downto 4);
sec2 <= "0011" & current_time.second(3 downto 0);
end if;
end if;
end process;

end behavioral;