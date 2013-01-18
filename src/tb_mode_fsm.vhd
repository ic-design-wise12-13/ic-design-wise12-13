-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  USE work.main_pkg.ALL;

  ENTITY testbench_fsm IS
  END testbench_fsm;

  ARCHITECTURE behavior OF testbench_fsm IS 

  -- Component Declaration
          COMPONENT mode_fsm
			 GENERIC ( num_modes : natural);
          PORT(
				uni:               in  universal_signals;
				keys:              in  keypad_signals;

				alarm_on:          in  std_logic; -- whether the alarm is ringing: force the alarm module to have keyboard focus

				keyboard_focus:    out std_logic_vector(num_modes - 1 downto 0); -- signal to each module whether it has keyboard focus
				visible:           out std_logic_vector(num_modes - 1 downto 0)  -- control signal to display_mux
           );
          END COMPONENT;

          
			 signal uni :  universal_signals;
          signal keys :  keypad_signals;
			 signal alarm_on : std_logic := '0';
			 signal keyboard_focus, visible : std_logic_vector (3 downto 0) := "0000";
          

  BEGIN

  -- Component Instantiation
          uut: mode_fsm GENERIC MAP (4)
								PORT MAP(
									uni => uni,
									keys => keys,
									alarm_on => alarm_on,
									keyboard_focus => keyboard_focus,
									visible => visible
								);


 --  clock generation
		process
		begin
		uni.clk <= '1';
		wait for 50 us;
		uni.clk <= '0';
		wait for 50 us;
		end process;
		
		
	-- 10Hz clock should look like this
		process
		begin
		uni.enable_10 <= '1';
		wait for 100 us;
		uni.enable_10 <= '0';
		wait for 99900 us;
		end process;

 --  Test Bench Statements
     tb : PROCESS
     BEGIN
			uni.reset <= '1';
			wait for 100 ns; -- wait until global set/reset completes
			uni.reset <= '0';
			
		-- twice all modes no adjustments
			for i in 0 to 7 loop
				keys.kc_mode_imp <= '1';
				wait for 100 us;
				keys.kc_mode_imp <= '0';
				wait for 300 us;
			end loop;
		
		-- test reset
			uni.reset <= '1'; wait for 100 us;
			uni.reset <= '0'; wait for 100 us; -- no action since already in reset state
			
			keys.kc_mode_imp <= '1'; wait for 100 us;
			keys.kc_mode_imp <= '0'; wait for 100 us;
			uni.reset <= '1'; wait for 100 us;
			uni.reset <= '0'; wait for 100 us; -- date to reset state
			
			for i in 0 to 1 loop
				keys.kc_mode_imp <= '1';
				wait for 100 us;
				keys.kc_mode_imp <= '0';
				wait for 100 us;
			end loop;
			uni.reset <= '1'; wait for 100 us;
			uni.reset <= '0'; wait for 100 us; -- alarm to reset state
			
			for i in 0 to 2 loop
				keys.kc_mode_imp <= '1';
				wait for 100 us;
				keys.kc_mode_imp <= '0';
				wait for 100 us;
			end loop;
			uni.reset <= '1'; wait for 100 us;
			uni.reset <= '0'; wait for 100 us; -- countdown to reset state
			
		-- modify alarm time
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to date
			keys.kc_mode_imp <= '0'; wait for 100 us;
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to alarm
			keys.kc_mode_imp <= '0'; wait for 100 us;
			keys.kc_act_imp <= '1'; wait for 100 us;	-- to alarm_mod
			keys.kc_act_imp <= '0'; wait for 100 us;
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to time
			keys.kc_mode_imp <= '0'; wait for 100 us;			

			
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to date
			keys.kc_mode_imp <= '0'; wait for 100 us;
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to alarm
			keys.kc_mode_imp <= '0'; wait for 100 us;
			keys.kc_plus_imp <= '1'; wait for 100 us; -- to alarm_mod
			keys.kc_plus_imp <= '0'; wait for 100 us;
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to time
			keys.kc_mode_imp <= '0'; wait for 100 us;

			keys.kc_mode_imp <= '1'; wait for 100 us; -- to date
			keys.kc_mode_imp <= '0'; wait for 100 us;
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to alarm
			keys.kc_mode_imp <= '0'; wait for 100 us;
			keys.kc_minus_imp <= '1'; wait for 100 us; -- to alarm_mod
			keys.kc_minus_imp <= '0'; wait for 100 us;
			uni.reset <= '1'; wait for 100 us;
			uni.reset <= '0'; wait for 100 us; -- to time via reset
				
		-- alarm ringing
			alarm_on <= '1', '0' after 1 ms; -- to alarm_ring and time
			wait for 1100 us;
			keys.kc_mode_imp <= '1', '0' after 100 us; -- to date
			wait for 400 us;
			alarm_on <= '1', '0' after 100 us; -- to alarm_ring and time
			wait for 200 us;
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to date
			keys.kc_mode_imp <= '0'; wait for 100 us;
			keys.kc_mode_imp <= '1'; wait for 100 us; -- to alarm
			keys.kc_mode_imp <= '0'; wait for 100 us;
			alarm_on <= '1', '0' after 200 us; -- to alarm_ring and time
			wait for 300 us;
			
		-- return to time_state after waiting 2,5s	
			keys.kc_mode_imp <= '1';
			wait for 100 us;
			keys.kc_mode_imp <= '0';
			wait for 3000 ms;
			
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
