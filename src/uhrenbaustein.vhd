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

signal uni              :universal_signals;
signal keys             :keypad_signals;
signal ctime            :time_signals;
signal char1            :character_array_1d; -- ??
          

signal alarm_active     :std_logic;
signal keyboard_focus   :std_logic_vector( (num_modes-1) downto 0);
signal visible          :std_logic_vector( (num_modes-1) downto 0);
signal sdow             :string(1 to 3);   --??



begin
su_on <= '0';

uni.clk <= clk;
uni.reset <= reset;



mode_alarm_inst: mode_alarm
  port map(
    uni => uni,
    key => key,
 );


end behavioral;
