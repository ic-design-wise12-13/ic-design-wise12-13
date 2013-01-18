-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  use work.main_pkg.all;

  ENTITY testbench_time IS
  END testbench_time;

  ARCHITECTURE behavior OF testbench_time IS 

  -- Component Declaration
          COMPONENT Time_State
          PORT(
					uni:               in  universal_signals;
					current_time:      in  time_signals;
					
					characters:        out character_array_2d(3 downto 0, 19 downto 0)
                  );
          END COMPONENT;
	--input
	signal	uni:                universal_signals;
	signal	current_time:       time_signals;
	--output	
	signal	characters:         character_array_2d(3 downto 0, 19 downto 0);
          

  BEGIN

  -- Component Instantiation
          uut: Time_State PORT MAP(
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
	
	
	  --  Test Bench Statements
  tb : PROCESS
  BEGIN
--		wait for 100 us;
--		current_time.minute <= "1011001";
--		current_time.second <= "1011001";
--		current_time.hour <= "100010";
--		current_time.valid <= '0';
--	  

--		
--		wait for 100 us;
--		current_time.minute <= "1011001";
--		current_time.second <= "1011001";
--		current_time.hour <= "100010";
--		current_time.valid <= '1';
		
		wait for 1000 ms;
		current_time.minute <= "1011010";
		current_time.second <= "1011000";
		current_time.hour <= "100010";
		current_time.valid <= '1';
		
		wait for 1000 ms;
		current_time.minute <= "1011010";
		current_time.second <= "1011001";
		current_time.hour <= "100010";
		current_time.valid <= '0';
		
		wait for 1000 ms;
		current_time.minute <= "1010011";
		current_time.second <= "1011001";
		current_time.hour <= "100010";
		current_time.valid <= '0';
		
		wait for 500 us;		
		uni.reset <= '1';
		wait for 100 us;
		uni.reset <= '0';

	 
  END PROCESS tb;

  END;
