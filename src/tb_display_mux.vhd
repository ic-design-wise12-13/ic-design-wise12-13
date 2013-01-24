-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  use work.main_pkg.all;

  ENTITY tb_display_mux IS
  END tb_display_mux;

  ARCHITECTURE behavior OF tb_display_mux IS 

          SIGNAL uni :  universal_signals;
          SIGNAL visible :  unsigned(3 downto 0);
			 signal module_characters : character_array_3d(3 downto 0, 3 downto 0, 19 downto 0);
			 signal characters : character_array_2d(3 downto 0, 19 downto 0);
          

  BEGIN

  -- Component Instantiation
          uut: display_mux 
					generic map (4)
					PORT MAP(
                  uni => uni,
                  visible => visible,
						module_characters => module_characters,
						characters => characters
					);


  --  Test Bench Statements
     tb : PROCESS
     BEGIN
			-- initiate array
			for i in 3 downto 0 loop
				for j in 19 downto 0 loop
					module_characters(3, i, j) <= x"aa"; -- time
					module_characters(2, i, j) <= x"bb"; -- date
					module_characters(1, i, j) <= x"cc"; -- alarm
					module_characters(0, i, j) <= x"dd"; -- countdown
				end loop;
			end loop;
			wait for 100 ns; -- wait until global set/reset completes

			visible <= "0000"; wait for 300 us; -- test time
			visible <= "0100"; wait for 300 us; -- test date
			visible <= "0010"; wait for 300 us; -- test alarm
			visible <= "0001"; wait for 300 us; -- test countdown
			visible <= "0000"; wait for 300 us; -- test time
			visible <= "1111"; wait for 300 us; -- test wrong signals
			visible <= "0101"; wait for 300 us; -- test wrong signals
						
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
