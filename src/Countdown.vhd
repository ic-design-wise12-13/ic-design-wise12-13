-- Project: Uhrenbaustein
-- Module: Countdown
-- Author: Tobias Fülle
-- Date:   14/11/2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;		
use work.main_pkg.all;	

entity Countdown is
      port(
		uni:               in  universal_signals;
		keys:              in  keypad_signals;
		current_time:      in  time_signals;
		keyboard_focus:    in  std_logic (3 downto 0); 

		characters:        out character_array_2d(3 downto 0, 19 downto 0);
		ti_on :		   out std_logic;
		ti_beep:           out std_logic
      );
end Countdown;

architecture Behavioral of Time_State is
	type character_array_1d is array(natural range <>) of unsigned(7 downto 0);
	type timer is (set, start, pause, beep);
	signal current_state, next_state : timer;
	signal hour, nhour, nmin, min, state, nstate : character_array_1d;
begin

process(uni.clk) 	
begin
	if(rising_edge(uni.clk)) then

		characters(0,19 downto 0) <= "                    "; -- time is left according to display_mux
		characters(1,19 downto 0) <= "                    ";
		characters(2,19 downto 0) <= "       Timer:       "; -- general char - output
		characters(3,19 downto 0) <= "       " + hour + ":" + min + "  " + state + "   ";

 		if(uni.reset = '1') then
			state <= "Off";
			hour  <= "00";
			min  <= "04";
			current_state <= set;
		else	
			current_state <= next_state;
			state <= nstate;
			hour <= nhour;
			min <= nmin;			
		end if;
	end if;
end process;

process(current_state, next_state) -- idea to use variables to get the current value immediately
	variable counter, counter1, counter2 : natural range 0 to 10000;
	variable initmin, inithour : natural range 0 to 60;
begin
case current_state is
	when set =>
		ti_on <= '0';
		ti_beep <= '0';
		nstate <= "Off";
		if(keyboard_focus = "0001") then
			if (keys.key_act_imp = '1') then
				initmin <= min;
				inithour <= hour;
				next_state <= start;				
			else
				next_state <= current_state;
			end if;
			if (keys.kc_plus_imp = '1') then
				if (min < 60) then
					nmin  <= min + 1;
					nhour <= hour;
				else
					nmin  <= "00";
					nhour <= hour + 1;
				end if;	
			elsif (keys.kc_minus_imp = '1') then
				if (min > "00" and hour > "00") then
					nmin  <= min - 1;
					nhour <= hour;
				elsif (min = "00" and hour > "00") then
					nmin  <= "59";
					nhour <= hour - 1;
				elsif (min = "00" and hour = "00") then
					nmin  <= "00";
					nhour <= "00";
				end if;	
			else
				nhour <= hour;
				nmin  <= min;
			end if;		
		end if;
	when start =>
		ti_on <= '1';
		ti_beep <= '0';
		nstate <= "On ";
		if (keys.key_act_imp = '1' AND keyboard_focus = "0001") then
			next_state <= pause;
		elsif (hour = "00" AND min="00") then
			next_state <= beep;
		else
			next_state <= current_state;
		end if;
		if(rising_edge(uni.enable1)) then
			if (counter2 < 60) then 
				counter2 := counter2 + 1;
			else
				counter2 := 0;
				if (min > "00" and hour > "00") then
					nmin  <= min - 1;
					nhour <= hour;
				elsif (min = "00" and hour > "00") then
					nmin  <= "59";
					nhour <= hour - 1;
				else
					nmin  <= "00";
					nhour <= "00";
				end if;	
			end if;
		end if;
	when pause =>
		nstate <= "On ";
		if(counter < 2500) then
			ti_on <= '1';
			counter := counter + 1;
		elsif(counter < 5000) then
			ti_on <= '0';
			counter := counter + 1;
		else
			ti_on <= '0';
			counter := '0';
		end if;	
		ti_beep <= '0';
		nmin <= min;
		nhour <= hour;
		if (keys.key_act_imp = '1' AND keyboard_focus = "0001") then
			next_state <= pause;
		else
			next_state <= current_state;
		end if;
	when beep  =>
		nstate <= "On ";
		nmin <= initmin;
		nhour <= inithour;
		if(counter1 < 10000) then
			ti_beep <= '1';
			counter1 := counter1 + 1;
			next_state <= current_state;
		else
			ti_beep <= '0';
			counter1 := '0';
			next_state <= set;
		end if;	
		ti_on <= '0';
	when others =>
		nmin <= "04";
		nhour <= "00";
		ti_on <= '0';
		ti_beep <= '0';
		nstate <= "Off";


end case;
end process;

end Behavioral;
