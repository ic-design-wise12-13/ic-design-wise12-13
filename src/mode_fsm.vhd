----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 	Fabian Achatz
-- 
-- Create Date:    11:00:49 11/08/2012 
-- Design Name: 	 
-- Module Name:    mode_fsm - Behavioral 
-- Project Name: 	 uhrenbaustein
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.main_pkg.ALL;


entity mode_fsm is
		generic( num_modes:         natural := 4);
		port(
					uni:               in  universal_signals;
					keys:              in  keypad_signals;

					alarm_on:          in  std_logic; -- whether the alarm is ringing: force the alarm module to have keyboard focus

					keyboard_focus:    out std_logic_vector(num_modes - 1 downto 0); -- signal to each module whether it has keyboard focus
					visible:           out std_logic_vector(num_modes - 1 downto 0)  -- control signal to display_mux
		);
end mode_fsm;


architecture Behavioral of mode_fsm is

signal cnt_reset : std_logic := '0';
signal counter : unsigned (4 downto 0) := "00000";
signal keyboard_foc : std_logic_vector (num_modes - 1 downto 0);

-- define type state and create signals for current and next state
type state is (time_state, date, alarm, alarm_mod, alarm_ring , countdown);
signal cur_state, next_state : state := time_state;

begin


-- next state logic
process (uni.clk, cur_state)
begin
	if uni.reset = '1' then
	next_state <= time_state;
	elsif	alarm_on = '1' then
	next_state <= alarm_ring;
	else
		case cur_state is
			when time_state =>
				if keys.kc_mode_imp = '1' then
				next_state <= date;
				else
				next_state <= cur_state;
				end if;
			when date =>
				if counter >= 25 then
				next_state <= time_state;
				elsif keys.kc_mode_imp = '1' then
				next_state <= alarm;
				else
				next_state <= cur_state;
				end if;
			when alarm =>
				if (keys.kc_plus_imp = '1' or keys.kc_minus_imp = '1' or keys.kc_act_imp = '1') then
				next_state <= alarm_mod;
				elsif keys.kc_mode_imp = '1' then
				next_state <= countdown;
				else
				next_state <= cur_state;
				end if;
			when alarm_mod =>
				if keys.kc_mode_imp = '1' then
				next_state <= time_state;
				else
				next_state <= cur_state;
				end if;
			when countdown =>
				if keys.kc_mode_imp = '1' then
				next_state <= time_state;
				else
				next_state <= cur_state;
				end if;
			when alarm_ring =>
				if alarm_on = '0' then
				next_state <= time_state;
				else
				next_state <= cur_state;
				end if;
		end case;
	end if;
end process;

-- output logic
process (cur_state)
begin
	case cur_state is
		when time_state =>
			keyboard_foc <= "1000";
			cnt_reset <= '1';
		when date =>
			keyboard_foc <= "0100";
			cnt_reset <= '0';
		when alarm =>
			keyboard_foc <= "0010";
			cnt_reset <= '1';
		when alarm_mod =>
			keyboard_foc <= "0010";
			cnt_reset <= '1';
		when alarm_ring =>
			keyboard_foc <= "0000";
			cnt_reset <= '1';
		when countdown =>
			keyboard_foc <= "0001";
			cnt_reset <= '1';
	end case;
end process;

-- state register
process (uni.clk)
begin
	if rising_edge(uni.clk) then
		if uni.reset = '1' then
		cur_state <= time_state;
		else
		cur_state <= next_state;
		end if;
	end if;
end process;

-- counter for state date
process (uni.enable_10)
begin
	if cnt_reset = '1' then
		counter <= "00000";
	elsif rising_edge(uni.enable_10) then
		counter <= counter + 1;
	end if;
end process;

visible <= keyboard_foc;
keyboard_focus <= keyboard_foc;

end Behavioral;

