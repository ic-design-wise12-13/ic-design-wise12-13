-- TestBench Template

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  use work.main_pkg.all;

  ENTITY tb_mode_date IS
  END tb_mode_date;

  ARCHITECTURE behavior OF tb_mode_date IS
  -- Component Declaration
   COMPONENT mode_date
   PORT(
 uni: in universal_signals;
 current_time: in time_signals;
 
 characters: out character_array_2d(3 downto 0, 19 downto 0)
   );
   END COMPONENT;
 --input
 SIGNAL uni : universal_signals := (others => '0');
 signal current_time : time_signals;
 
 -- output
 SIGNAL characters : character_array_2d(3 downto 0, 19 downto 0);
 

  BEGIN

  -- Component Instantiation
 uut: mode_date PORT MAP(
uni => uni,
current_time => current_time,
characters => characters
 );

   -- Clock process definitions
   uni_clk_process :process
   begin
uni.clk <= '0';
wait for 50 us;
uni.clk <= '1';
wait for 50 us;
   end process;


  -- Test Bench Statements
  tb : PROCESS
  BEGIN
wait for 100 us;
current_time.dayofweek <= "001";
current_time.day <= "101001";
current_time.month <= "10001";
current_time.year <= "10011001";

      wait for 1000 ms;	
uni.reset <= '1';
wait for 100 us;
uni.reset <= '0';

wait for 1000 ms;
current_time.dayofweek <= "001";
current_time.day <= "101001";
current_time.month <= "10001";
current_time.year <= "10011001";

wait for 1000 ms;
  END PROCESS tb;


  END;