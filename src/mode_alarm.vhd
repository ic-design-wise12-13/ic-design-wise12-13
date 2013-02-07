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
    ALARM_RING,   -- alarm is ringing
    SNOOZE,      -- alarm is delayed by the snooze period
    ALARM_OFF    -- alarm is not currently ringing
  );
  signal alarm_state      :alarm_state_t;

  signal snooze_hour      :unsigned(5 downto 0);
  signal snooze_minute    :unsigned(6 downto 0);
  signal alarm_hour       :unsigned(5 downto 0);
  signal alarm_minute     :unsigned(6 downto 0);

  signal alarm_active_int :std_logic;

  signal char2            :string(1 to 20); -- characters line 3
  signal char3            :string(1 to 20); -- characters line 4
  signal hour1, hour2, min1, min2 : unsigned(7 downto 0); 

begin

-- Set alarm time, activate alarm

  process(uni.clk)
  begin
    if rising_edge(uni.clk) then
    -- RESET
      if uni.reset = '1' then
        alarm_hour<="000000";
        alarm_minute<="0000111"; -- 7 minuten
        alarm_active_int <= '0';

      elsif keyboard_focus = '1' then -- check keyboard focus
        -- set alarm time
        if alarm_state = ALARM_OFF or alarm_state = SNOOZE then

          --reduce time with pulse train
          if (keys.kc_enable = '1') and (keys.kc_up_dn = '0') then
            if alarm_minute="0000000" then                        -- Reduce hours
              if alarm_hour="000000" then                     -- go before Midnight
                alarm_hour<="100011";                         -- 23 hrs
              else
                if (alarm_hour(3 downto 0) = "0000") then
                  alarm_hour(5 downto 4) <= alarm_hour(5 downto 4) -1;
                  alarm_hour(3 downto 0) <= "1001";
                else
                  alarm_hour <= alarm_hour -1;
                end if;
              end if;
              alarm_minute<="1011001";                        -- 59 minutes
            else -- normal jump of just one minute
              if alarm_minute(3 downto 0) = "0000" then
                alarm_minute(6 downto 4) <= alarm_minute(6 downto 4) -1;
                alarm_minute(3 downto 0) <= "1001";
              else
                alarm_minute <= alarm_minute -1;
              end if;
            end if;
          -- increase time with pulse train
          elsif  (keys.kc_enable = '1') and (keys.kc_up_dn = '1') then
            if alarm_minute="1011001" then -- 59 minutes
              if alarm_hour="100011" then -- 23 hours
                alarm_hour<="000000";
              else
                if alarm_hour(3 downto 0) /="1001" then
                  alarm_hour<= alarm_hour+1;
                else 
                  alarm_hour(5 downto 4) <= alarm_hour(5 downto 4) +1;
                  alarm_hour(3 downto 0) <= "0000";
                end if;
              end if;
              alarm_minute<="0000000";
            else
              if alarm_minute(3 downto 0) /= "1001" then
                alarm_minute <= alarm_minute +1;
              else 
                alarm_minute(6 downto 4) <= alarm_minute(6 downto 4) +1;
                alarm_minute(3 downto 0) <= "0000";
              end if;
            end if;
      -- Alarm active/inactive
          elsif keys.kc_act_imp = '1' then
            alarm_active_int <= not alarm_active_int;
          end if;
        end if;
      end if;
    end if;
  end process;


-- Prepare Variables for Display
-- Constant
      char2(2 to 20)<="     Alarm:        ";
      char3(1 to 7)<="       ";
      char3(10)<=':';
      char3(13 to 20)<="        ";
-- variables 
  process(uni.clk)
  begin
    if(rising_edge(uni.clk))then
      hour1<= "001100" & alarm_hour(5 downto 4);  -- concatenation: Binary 0, 
      hour2<= "0011" & alarm_hour(3 downto 0);
      min1<= "00110" & alarm_minute(6 downto 4);
      min2<= "0011" & alarm_minute(3 downto 0);
    end if;
  end process;


-- Print Display

  process(char2, char3, hour1, hour2, min2, min1, alarm_active_int)    -- or time synchronous??
  begin
--    if rising_edge(uni.clk) then
      for row in 0 to 3 loop
        for col in 0 to 19 loop
          if (row = 2) and (col = 0) then
            if alarm_active_int = '1' then
              characters(row,col) <= "00101010"; -- alarm active, print star
            else
              characters(row,col) <= "00100000"; -- print space
            end if;
          elsif (row = 2) and (col >= 1) then
            characters(row,col) <= to_unsigned(character'pos(char2(col+1)), 8);
          elsif (row = 3) and (col <= 6) then
            characters(row,col) <= to_unsigned(character'pos(char3(col+1)), 8);
          elsif (row = 3) and (col = 7) then
            characters(row,col) <= hour1;
          elsif (row = 3) and (col = 8) then
            characters(row,col) <= hour2;
          elsif (row = 3) and (col = 9) then
            characters(row,col) <= to_unsigned(character'pos(char3(col+1)), 8);
          elsif (row = 3) and (col = 10) then
            characters(row,col) <= min1;
          elsif (row = 3) and (col = 11) then
            characters(row,col) <= min2;
          elsif (row = 3) and (col >= 12) then
            characters(row,col) <= to_unsigned(character'pos(char3(col+1)), 8);
          end if;
        end loop;
      end loop;
--    end if;
  end process;

-- AlarmOn FSM
  process(uni.clk)
  variable snooze_add_hour    :unsigned (5 downto 0);
  variable snooze_add_minute  :unsigned (6 downto 0);
  begin
    if rising_edge(uni.clk) then
      if uni.reset = '1' then
        alarm_state <= ALARM_OFF;
      --elsif alarm_active_int = '1' then -- check if alarm active
      elsif alarm_state=ALARM_OFF then
        if alarm_active_int = '1' then -- check if alarm active
          if ((alarm_hour=ctime.hour)and(alarm_minute=ctime.minute)and(ctime.second=0)) then
            alarm_state<=ALARM_RING;
            alarm_on<='1';
            al_on<='1';
            snooze_hour<=alarm_hour;
            snooze_minute<=alarm_minute;
          end if;
        end if;
      elsif (alarm_state=ALARM_RING) then
        if keys.kc_act_imp='1' then
          alarm_state<=SNOOZE;
          alarm_on<='0';
          al_on<='0';
          snooze_add_hour := snooze_hour;
          snooze_add_minute := snooze_minute;
          for i in 0 to 4 loop -- add 1 minute five times
            if snooze_add_minute="1011001" then -- 59 mins
              if snooze_add_hour="100011" then -- 23 hrs
                snooze_add_hour:="000000";
              else
                if snooze_add_hour(3 downto 0) /= "1001" then
                  snooze_add_hour:=snooze_add_hour + 1;
                else
                  snooze_add_hour(5 downto 4) := snooze_add_hour(5 downto 4) +1;
                  snooze_add_hour(3 downto 0) := "0000";
                end if;  
              end if;
              snooze_add_minute:="0000000";
            else
              if snooze_add_minute(3 downto 0) /= "1001" then
                snooze_add_minute := snooze_add_minute +1;
              else 
                snooze_add_minute(6 downto 4) := snooze_add_minute(6 downto 4) +1;
                snooze_add_minute(3 downto 0) := "0000";
              end if;
            end if;
          end loop;
          snooze_hour<=snooze_add_hour;
          snooze_minute<=snooze_add_minute;
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
          alarm_state<=ALARM_RING;
          al_on<='1';
          alarm_on<='1';
        end if;
      end if;
    end if;
  end process;

  alarm_active <= alarm_active_int;

end architecture; 
