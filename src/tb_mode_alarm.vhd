library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.main_pkg.all;

entity tb_mode_alarm is
end entity;


architecture behavioral of tb_mode_alarm is
  -- Inputs
  signal uni            :universal_signals := (others => '0');
  signal keys           :keypad_signals := (others => '0');
  signal keyboard_focus :std_logic;
  signal ctime          :time_signals; -- := (others => '0');
  -- Outputs
  signal characters     :character_array_2d(3 downto 0, 19 downto 0);
  signal alarm_active   :std_logic;
  signal alarm_on       :std_logic;
  signal al_on          :std_logic;


begin
  uut: mode_alarm port map (
    uni             => uni,
    keys            => keys,
    keyboard_focus  => keyboard_focus,
    ctime           => ctime,
    characters      => characters,
    alarm_active    => alarm_active,
    alarm_on        => alarm_on,
    al_on           => al_on
  );

 

  -- clock
  uni_clk_process: process
  begin
    uni.clk <= '0';
    wait for 50 us;
    uni.clk <= '1';
    wait for 50 us;
  end process;

  uni_1hz_process: process
  begin
    uni.enable_1 <= '0';
    wait for 500 ms;
    uni.enable_1 <= '1';
    wait for 500 ms;
  end process;

  tb_mode_alarm: process
  begin
    wait for 100 us;

-- reset
    ctime.hour<="000000";
    ctime.minute<="0000000";
    ctime.second<="0000000";
    uni.reset <= '1';
    wait for 100 us;
    uni.reset <= '0';
    wait for 100 us;

    keyboard_focus <= '1';
    wait for 100 us;
    --decrease 10 minutes from 0:07
    for i in 0 to 9 loop
      keys.kc_enable <= '1';
      keys.kc_up_dn <= '0';
      wait for 100 us;
      keys.kc_enable <= '0';
      wait for 100 us;
    end loop;
    -- increase back
	 for i in 0 to 9 loop
      keys.kc_enable <= '1';
      keys.kc_up_dn <= '1';
      wait for 100 us;
      keys.kc_enable <= '0';
      wait for 100 us;
    end loop;
	 -- alarm time, not active
	 ctime.hour<="000000";
    ctime.minute<="0000111";
    ctime.second<="0000000";
	 wait for 100 us;

	 -- 1 second past alarm
	 ctime.hour<="000000";
    ctime.minute<="0000111";
    ctime.second<="0000001";
	 wait for 100 us;
	 -- activate alarm
    keys.kc_act_imp <= '1';
	 wait for 100 us;
    -- alarm time
	 ctime.hour<="000000";
    ctime.minute<="0000111";
    ctime.second<="0000000";-- alarm time, alarm not activated
    -- snooze
	 keys.kc_act_imp <= '1';
	 wait for 100 us;

-- snooze
-- deactivate with button
-- deactivate by waiting



  end process tb_mode_alarm;
end architecture;
