library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.main_pkg.all;

entity mode_alarm is
  port(
-- clk, reset
    uni                 :in  universal_signals;
-- kc_minus_imp, kc_plus_imp, kc_act_imp
    keys                :in  keypad_signals;
-- current_time
    ctime               :in  time_signals;
    keyboard_focus      :in  std_logic;
-- output, mode_alarm is 1 ??
    characters          :out character_array_2d(3 downto 0, 19 downto 0);
    alarm_active        :out std_logic;
-- alarm is ringing
    alarm_on            :out std_logic;
-- alarm LED
    al_on               :out std_logic
  );
end mode_alarm;

architecture behavioral of mode_alarm is
  type alarm_state_t is (
    ALARM_ONA,
    ALARM_ONB,
    SNOOZE,
    ALARM_OFF
  );
  signal alarm_state    :alarm_state_t;

  signal snooze_hour   :unsigned(5 downto 0);
  signal snooze_minute :unsigned(6 downto 0);
  signal alarm_hour    :unsigned(5 downto 0);
  signal alarm_minute  :unsigned(6 downto 0);

  signal alarm_active_int: std_logic;

begin


  process(uni.clk)
    variable star       :character;
  begin
    if rising_edge(uni.clk) then
    -- RESET
      if uni.reset = '1' then
        alarm_hour<="000000";
        alarm_minute<="0000111"; -- 7 minuten

      elsif keyboard_focus = '1' then -- check keyboard focus
        if alarm_active_int='0' then
      -- set Alarm time
          if (keys.kc_enable = '1') and (keys.kc_up_dn = '0') then    -- reduce time with pulse train
            if alarm_minute="0000000" then -- Reduce hours
              if alarm_hour="000000" then -- go before Midnight
                alarm_hour<="010111"; -- 23 hrs
              else
                alarm_hour<= alarm_hour;
              end if;
              alarm_minute<="0111011"; -- 59 minutes
            else -- normal jump of just one minute
              alarm_minute <= alarm_minute -1;
            end if;
          elsif  (keys.kc_enable = '1') and (keys.kc_up_dn = '1') then   -- increase time with pulse train
            if alarm_minute="0111011" then -- 59 minutes
              if alarm_hour="010111" then -- 23 hours
                alarm_hour<="000000";
              else
                alarm_hour<=alarm_hour;
              end if;
              alarm_minute<="0000000";
            else
              alarm_minute <= alarm_minute + 1;
            end if;
      -- Alarm active/inactive
          elsif keys.kc_act_imp = '1' then
            alarm_active_int <= not alarm_active_int; -- negate current value (??)
            if alarm_active_int = '1' then
              star:='*';
            else
              star:=' ';
            end if;
          end if;
      -- print display output
     --   characters(1,2,19 downto 0) <= star+"     Alarm:        "; -- display output
        --characters(2,19 downto 0) <= "      Alarm:        "; -- display output
        --characters(3,19 downto 0) <= " "+to_integer(alarm_hour)+":"+to_integer(alarm_minute)+" ";
        end if;
      end if;
    end if;
  end process;



-- AlarmOn FSM
  process(uni.clk)
  begin
    if rising_edge(uni.clk) then
      if alarm_active_int = '1' then -- check if alarm active
        if alarm_state=ALARM_OFF then
          if ((alarm_hour=ctime.hour)and(alarm_minute=ctime.minute)) then
            alarm_state<=ALARM_ONA;
            alarm_on<='1';
            al_on<='1';
            snooze_hour<=alarm_hour;
            snooze_minute<=alarm_minute;
          end if;
        elsif (alarm_state=ALARM_ONA) or (alarm_state=ALARM_ONB) then
          if keys.kc_act_imp='1' then
            alarm_state<=SNOOZE;
            alarm_on<='0';
            al_on<='0';
            for i in 0 to 4 loop -- add 1 minute five times
              if snooze_minute="0111011" then -- 59 mins
                if snooze_hour="010111" then -- 23 hrs
                  snooze_hour<="000000";
                else
                  snooze_hour<=snooze_hour + 1;
                end if;
                snooze_minute<="0000000";
              else
                snooze_minute<=snooze_minute + 1;
              end if;
            end loop;
          elsif keys.kc_act_long='1' then
            alarm_state<=ALARM_OFF;
            al_on<='0';
            alarm_on<='0';
          elsif snooze_minute/=ctime.minute then -- now about one minute should have passed
            alarm_state<=ALARM_OFF;
            al_on<='0';
            alarm_on<='0';
          end if;
        elsif alarm_state=SNOOZE then
          if (snooze_hour=ctime.hour)and(snooze_minute=ctime.minute) then
            alarm_state<=ALARM_ONB;
            al_on<='1';
            alarm_on<='1';
          end if;
        end if;
      end if;
    end if;
  end process;

  alarm_active <= alarm_active_int;

end architecture; 
