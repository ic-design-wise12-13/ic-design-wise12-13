library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.main_pkg.all;

entity uhrenbaustein is
  generic(num_modes: natueral:=4);
  port(
    clk,
    reset,
    enable_1, enable_10, enable_50, enable_100,
    de_dcf_set,
    kc_up_dn, kc_enable, kc_act_long, kc_plus_imp, kc_minus_imp, kc_act_imp, kc_mode_imp
                              :in std_logic;
    de_dcf_dayofweek          :in std_logic_vector(2 downto 0);
    de_dcf_day, de_dcf_hour   :in std_logic_vector(5 downto 0);
    de_dcf_month              :in std_logic_vector(4 downto 0);
    de_dcf_year               :in std_logic_vector(7 downto 0);
    de_dcf_minute             :in std_logic_vector(6 downto 0);

    al_on,
    su_on,
    ti_on, ti_beep,
    d_en, d_rw, d_rs          :out std_logic;
    d_data                    :out std_logic_vector(7 downto 0)
  );
end uhrenbaustein;

architecture behavioral of uhrenbaustein is

signal uni                    :universal_signals;
signal keys                   :keypad_signals;
signal ctime                  :time_signals;

signal alarm_active           :std_logic;
signal visible                :std_logic_vector( (num_modes-1) downto 0);
signal all_char               :character_array_3d( (num_modes-1) downto 0, 3 downto 0, 7 downto 0); 
signal time_char              :character_array_2d( 3 downto 0, 19 downto 0);
signal m_date_char            :character_array_2d( 3 downto 0, 19 downto 0);
signal m_alarm_char           :character_array_2d( 3 downto 0, 19 downto 0);
signal m_countdown_char       :character_array_2d( 3 downto 0, 19 downto 0);
signal display_char           :character_array_2d( 3 downto 0, 19 downto 0);
signal keyboard_focus         :unsigned( (num_modes-1) downto 0);


begin
su_on <= '0';    -- set unused variable to 0

all_char(0, 3 downto 0, 19 downto 0) <= m_countdown_char;  -- put display outputs together
all_char(1, 3 downto 0, 19 downto 0) <= m_alarm_char;
all_char(2, 3 downto 0, 19 downto 0) <= m_date_char;
all_char(3, 3 downto 0, 19 downto 0) <= time_char;


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
  port map(
    uni => uni,
    visible => visible,
    module_characters => all_char,
    characters => display_char,
 );


mode_alarm_inst: mode_alarm
  port map(
    uni => uni,
    key => key,
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
    characters => m_countdown_char,
    ti_on => ti_on,
    ti_beep => ti_beep
 );

mode_date_inst: mode_date
  port map(
    uni => uni,
    current_time => ctime,
    characters => m_date_char
 );

mode_fms_inst: mode_fsm
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


end behavioral;
