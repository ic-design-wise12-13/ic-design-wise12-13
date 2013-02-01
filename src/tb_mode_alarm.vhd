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


  tb_mode_alarm: process
  begin
    wait for 100 us;

-- reset
    uni.reset <= '1';
    wait for 100 us;
    uni.reset <= '0';
    wait for 100 us;

    keyboard_focus <= '1';
    wait for 100 us;
-- decrease 10 minutes from 5:40
--    alarm_hour <= ????
--    for i in 0 to 9 loop
--      keys.kc_enable = '1';
--      keys.kc_up_dn = '0';
--      wait for 100 us;
--      keys.kc_enable = '0';
--      wait for 100 us;
--    end loop;
    
-- increase 10 minutes from 18:15   

-- decrease hours
  -- normal 9:00 -> 8:59
  -- normal 10:00 -> 9:59
  -- past midnight 0:00 -> 23:59

-- increase hours
  -- normal 8:59 -> 9:00
  -- normal 9:59 -> 10:00
  -- past midnight 23:59 -> 0:00

-- alarm time, alarm not activated
-- alarm time, alarm activated
-- snooze
-- deactivate with button
-- deactivate by waiting



  end process tb_mode_alarm;
end architecture;
