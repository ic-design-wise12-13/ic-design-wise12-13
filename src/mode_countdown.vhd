-- Project: Uhrenbaustein
-- Module: Countdown
-- Author: Tobias Fülle
-- Date:   14/11/2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;		
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.main_pkg.all;	

entity mode_countdown is
      port(
		uni:               in  universal_signals;
		keys:              in  keypad_signals;
		keyboard_focus:    in  std_logic_vector (3 downto 0); 
		
		characters:        out character_array_2d(3 downto 0, 19 downto 0);		
		ti_on :		   	 out std_logic;
		ti_beep:           out std_logic
      );
end mode_countdown;

architecture behavioral of mode_countdown is
	type timer is (set, start, pause, beep);
	type int_array is array(1 downto 0) of integer range 0 to 9;
	type int_array3 is array(3 downto 0) of integer range 0 to 9;	
	signal cnt_reset : std_logic := '0';
	signal counter : integer range 0 to 600000 := 0;
	signal current_state, next_state : timer;
	signal char : string (1 to 80);
	signal state, nstate : string (3 downto 1);
	signal nhour, nmin,hour,min, inithour, initmin, nihour, nimin : int_array;  

-- internal function for plus operation
function plus(m,h: in int_array) return int_array3 is
	variable dispout: int_array3;
begin
				if (m(1) = 5 and m(0) = 9) then
					dispout(1) := 0;
					dispout(0) := 0;
					if(h(0) = 9) then
						dispout(3) := h(1) + 1;
						dispout(2) := 0;
					else
						dispout(3) := h(1);
						dispout(2) := h(0) + 1;
					end if;
				else
					if(m(0) = 9) then
						dispout(1) := m(1) + 1;
						dispout(0) := 0;
					else
						dispout(1) := m(1);
						dispout(0) := m(0) + 1;
					end if;
					dispout(3) := h(1);
					dispout(2) := h(0);
				end if;	
return dispout;
end function;

--internal function for minus operation
function minus(m,h: in int_array) return int_array3 is
	variable dispout: int_array3;
begin
				if (m(1) > 0 or m(0) > 0) then
					if(m(0) = 0) then
						dispout(1)  := m(1) - 1;
						dispout(0) := 9;
					else
						dispout(1) := m(1);
						dispout(0) := m(0) - 1;
					end if;
					dispout(2) := h(0);
					dispout(3) := h(1);
				elsif (m(1) = 0 and m(0) = 0 and (h(1) > 0 or h(0) > 0)) then
					dispout(3) := 5;
					dispout(2) := 9;
					if(h(0) = 0 and h(1) > 0) then
						dispout(3) := h(1) - 1;
						dispout(2) := 9;					
					else
						dispout(3) := h(1);
						dispout(2) := h(0) - 1;
					end if;
				else 
					dispout(1) := 0;
					dispout(0) := 0;
					dispout(3) := 0;
					dispout(2) := 0;
				end if;	
return dispout;
end function;


begin

-- constant assignment of character output:
char(1 to 80) <= "                                               Timer:                " & ':' & "          ";

-- assignment of 2d character-array output
process(char,state, hour, min)
begin
		for row in 0 to 3 loop
			for col in 0 to 19 loop
				if(row = 3 AND col = 8) then
					characters(row,col) <= to_unsigned(min(1),8);
				elsif(row = 3 AND col = 9) then					
					characters(row,col) <= to_unsigned(min(0),8);
				elsif(row = 3 AND col = 11) then					
					characters(row,col) <= to_unsigned(hour(1),8);
				elsif(row = 3 AND col = 12) then					
					characters(row,col) <= to_unsigned(hour(0),8);
				elsif(row = 3 AND col = 15) then					
					characters(row,col) <= to_unsigned(character'pos(state(3)),8);
				elsif(row = 3 AND col = 16) then					
					characters(row,col) <= to_unsigned(character'pos(state(2)),8);
				elsif(row = 3 AND col = 17) then					
					characters(row,col) <= to_unsigned(character'pos(state(1)),8);
				else
					characters(row, col) <= to_unsigned(character'pos(char(20*row + col + 1)), 8);
				end if;
			end loop;
		end loop;
end process;

--synchron control and counter
process(uni.clk) 
variable count : integer range 0 to 6000 := 0;
begin
	if(rising_edge(uni.clk)) then
	
 		if(uni.reset = '1') then 
			state <= "Off";
			hour(1) <= 0;
			hour(0) <= 0;
			min(1)  <= 0;
			min(0)  <= 4;
			current_state <= set;
			count := 0;
			inithour(1) <= 0;
			inithour(0) <= 0;
			initmin(1) <= 0;
			initmin(0) <= 4;
		else	
			if (cnt_reset = '1') then 
				count := 0;
			else
				count := count + 1;
			end if;
			current_state <= next_state;
			state <= nstate;
			hour <= nhour;			
			min <= nmin;
			inithour <= nihour;
			initmin <= nimin;
		end if;
	end if;
	counter <= count;
end process;

--next state and output
process(current_state,next_state,keyboard_focus,keys.kc_act_imp,keys.kc_plus_imp,keys.kc_minus_imp, min, hour, counter, initmin, inithour)
	variable temp : int_array3;
begin
case current_state is
	when set =>
		ti_on <= '0';
		ti_beep <= '0';
		nstate <= "Off";
		if(keyboard_focus = "0001" AND keys.kc_act_imp = '1') then 
			nimin <= min;
			nihour <= hour;
			next_state <= start;				
		else
			nimin <= initmin;
			nihour <= inithour;
			next_state <= current_state;
		end if;
		cnt_reset <= '0';
		if (keyboard_focus = "0001" AND keys.kc_plus_imp = '1') then 
			temp := plus(min, hour);
			nmin(1) <= temp(1);
			nmin(0) <= temp(0);
			nhour(1) <= temp(3);
			nhour(0) <= temp(2);		
		elsif (keyboard_focus = "0001" AND keys.kc_minus_imp = '1') then 
			temp := minus(min, hour);
			nmin(1) <= temp(1);
			nmin(0) <= temp(0);
			nhour(1) <= temp(3);
			nhour(0) <= temp(2);
		else
			nhour <= hour;
			nmin <= min;
		end if;	
		
	when start =>
		ti_on <= '1';
		ti_beep <= '0';
		nstate <= "On ";		
		if (keyboard_focus = "0001" AND keys.kc_act_imp = '1') then 
			next_state <= pause;			
		elsif (hour(1) = 0 AND hour(0) = 0 AND min(1) = 0 and min(0) = 0) then			
			next_state <= beep;
		else
			next_state <= current_state;			
		end if;		
		if (counter < 600000) then 
			nhour <= hour;
			nmin <= min;
			cnt_reset <= '0';
		else
			temp := minus(min, hour);
			nmin(1) <= temp(1);
			nmin(0) <= temp(0);
			nhour(1) <= temp(3);
			nhour(0) <= temp(2);			
			cnt_reset <= '1';
		end if;
			nimin <= initmin;
			nihour <= inithour;		
	when pause =>
		ti_beep <= '0';
		nstate <= "On ";
		if(counter < 2500) then
			ti_on <= '1';
			cnt_reset <= '0';
		elsif(counter < 5000) then
			ti_on <= '0';
			cnt_reset <= '0';
		else
			ti_on <= '0';
			cnt_reset <= '1';
		end if;	
		if (keyboard_focus = "0001" AND keys.kc_act_imp = '1') then 
			next_state <= start;
		else
			next_state <= current_state;
		end if;
		nmin <= min;
		nhour <= hour;
		nimin <= initmin;
		nihour <= inithour;
	when beep  =>
		nstate <= "On ";
		ti_on <= '0';				
		if(counter < 10000) then
			cnt_reset <= '0';
			ti_beep <= '1';
			next_state <= current_state;			
		else
			cnt_reset <= '1';
			ti_beep <= '0';
			next_state <= set;
		end if;	
		nmin <= initmin;
		nhour <= inithour;
		nimin <= initmin;
		nihour <= inithour;
	when others =>
		next_state <= set;
		ti_on <= '0';
		ti_beep <= '0';
		nstate <= "Off";
		cnt_reset <= '1';
		nmin(0) <= 4;
		nmin(1) <= 0;
		nhour(1) <= 0;
		nhour(0) <= 0;
		nimin <= initmin;
		nihour <= inithour;
end case;
end process;

end Behavioral;
