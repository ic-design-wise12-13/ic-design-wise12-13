library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.main_pkg.all;

entity uhrenbaustein is
  generic(num_modes: natural:=4);
  port(
    clk,
    reset,
    enable_1, enable_10, enable_50, enable_100,
    de_dcf_set,
    kc_up_dn, kc_enable, kc_act_long, kc_plus_imp, kc_minus_imp, kc_act_imp, kc_mode_imp
                              :in std_logic;
    de_dcf_dayofweek          :in unsigned(2 downto 0);
    de_dcf_day, de_dcf_hour   :in unsigned(5 downto 0);
    de_dcf_month              :in unsigned(4 downto 0);
    de_dcf_year               :in unsigned(7 downto 0);
    de_dcf_minute             :in unsigned(6 downto 0);

    al_on,
    su_on,
    ti_on, ti_beep,
    d_en, d_rw, d_rs          :out std_logic;
    d_data                    :out unsigned(7 downto 0)
  );
end uhrenbaustein;

architecture behavioral of uhrenbaustein is

signal uni                    :universal_signals;
signal keys                   :keypad_signals;
signal ctime                  :time_signals;
signal dcf_time               :time_signals;

signal alarm_active           :std_logic;
signal alarm_on               :std_logic;
signal visible                :unsigned( (num_modes-1) downto 0);
signal all_char               :character_array_3d_HACK(num_modes - 1 downto 0);
signal time_char              :character_array_2d( 3 downto 0, 19 downto 0);
signal m_date_char            :character_array_2d( 3 downto 0, 19 downto 0);
signal m_alarm_char           :character_array_2d( 3 downto 0, 19 downto 0);
signal m_cdown_char       :character_array_2d( 3 downto 0, 19 downto 0);
signal display_char           :character_array_2d( 3 downto 0, 19 downto 0);
signal keyboard_focus         :unsigned( (num_modes-1) downto 0);


begin
su_on <= '0';    -- set unused variable to 0

process(m_cdown_char, m_alarm_char, m_date_char, time_char)
begin
	for row in 0 to 3 loop
		for col in 0 to 19 loop
			all_char(0)(row, col) <= m_cdown_char(row, col);  -- put display outputs together
			all_char(1)(row, col) <= m_alarm_char(row, col);
			all_char(2)(row, col) <= m_date_char(row, col);
			all_char(3)(row, col) <= time_char(row, col);
		end loop;
	end loop;
end process;



uni.clk <= clk;
uni.reset <= reset;
uni.enable_1 <= enable_1;
uni.enable_10 <= enable_10;
uni.enable_50 <= enable_50;
uni.enable_100 <= enable_100;

keys.kc_up_dn <= kc_up_dn;
keys.kc_enable <= kc_enable;
keys.kc_act_long <= kc_act_long;
keys.kc_plus_imp <= kc_plus_imp;
keys.kc_minus_imp <= kc_minus_imp;
keys.kc_act_imp <= kc_act_imp;
keys.kc_mode_imp <= kc_mode_imp;

dcf_time.dayofweek <= de_dcf_dayofweek;
dcf_time.day <= de_dcf_day;
dcf_time.hour <= de_dcf_hour;
dcf_time.month <= de_dcf_month;
dcf_time.year <= de_dcf_year;
dcf_time.minute <= de_dcf_minute;
dcf_time.second <= "0000000";
dcf_time.valid <= de_dcf_set;


display_driver_inst: display_driver
  port map(
    -- name in modul  => name here 
    uni => uni,
    characters => display_char,
    d_en => d_en,
    d_rw => d_rw,
    d_rs => d_rs,
    d_data => d_data
 );

display_mux_inst: display_mux
  generic map(
    num_modes => num_modes
  )
  port map(
    uni => uni,
    visible => visible,
    module_characters => all_char,
    characters => display_char
 );


mode_alarm_inst: mode_alarm
  port map(
    uni => uni,
    keys => keys,
    ctime => ctime,
    keyboard_focus => keyboard_focus(1),
    characters => m_alarm_char,
    alarm_active => alarm_active,
    alarm_on => alarm_on,
    al_on => al_on
 );

mode_countdown_inst: mode_countdown
  port map(
    uni => uni,
    keys => keys,
    keyboard_focus => keyboard_focus(0),
    characters => m_cdown_char,
    ti_on => ti_on,
    ti_beep => ti_beep
 );

mode_date_inst: mode_date
  port map(
    uni => uni,
    current_time => ctime,
    characters => m_date_char
 );

mode_fsm_inst: mode_fsm
  generic map(
    num_modes => num_modes
  )
  port map(
    uni => uni,
    keys => keys,
    alarm_on => alarm_on,
    keyboard_focus => keyboard_focus,
    visible => visible
 );

mode_time_inst: mode_time
  port map(
    uni => uni,
    current_time => ctime,
    characters => time_char
  );

time_buffer_inst: time_buffer
  -- uncomment the following lines for easy testing of alarm functionality
  generic map(
    clock_divider => 1000,
    ignore_dcf => true,
    reset_time => ("110", "000001", "010011", "00001", x"00", "0110111", "0000000", '0') -- Sat January 1, 2000, 13:37:00, invalid
  )
  port map(
    uni => uni,
    time_in =>  dcf_time,
    time_out => ctime
  );

end behavioral;
