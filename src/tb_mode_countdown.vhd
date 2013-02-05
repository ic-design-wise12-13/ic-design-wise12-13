-- Project: Uhrenbaustein
-- Module: tb_mode_countdown
-- Author: Tobias Flle
-- Date: 14/11/2012


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.main_pkg.all;	

 
ENTITY tb_mode_countdown IS
END tb_mode_countdown;
 
ARCHITECTURE behavior OF tb_mode_countdown IS
          COMPONENT mode_countdown
          PORT(
				uni: in universal_signals;
				keys: in keypad_signals;
				keyboard_focus: in std_logic;

				characters: out character_array_2d(3 downto 0, 19 downto 0);	
				ti_on :	out std_logic;
				ti_beep: out std_logic
                  );
          END COMPONENT;


   --Inputs
signal uni: universal_signals := (others => '0');
signal keys: keypad_signals := (others => '0');
   signal keyboard_focus : std_logic; -- _vector(3 downto 0) := (others => '0');

  --Outputs
signal characters: character_array_2d(3 downto 0, 19 downto 0);
   signal ti_on : std_logic;
   signal ti_beep : std_logic;

 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
   uut: mode_countdown PORT MAP (
uni => uni,
keys => keys,
          keyboard_focus => keyboard_focus,
characters => characters,
          ti_on => ti_on,
          ti_beep => ti_beep
        );

   -- Clock process definitions
   uni_clk_process :process
   begin
uni.clk <= '0';
wait for 50 us;
uni.clk <= '1';
wait for 50 us;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
      -- hold reset state for 100 ns.
      wait for 100 us;	
		keys.kc_up_dn <= '1';
uni.reset <= '1';
wait for 100 us;
uni.reset <= '0';
wait for 100 us;
keyboard_focus <= '1'; --"0001";
wait for 100 us;
keys.kc_enable <= '1';
wait for 6000 ms;
keys.kc_enable <= '0'; -- count up to ...
wait for 100 us;
uni.reset <= '1';
wait for 100 us;
uni.reset <= '0';	    -- set time back to 0:04
keys.kc_up_dn <= '0';

wait for 100 us;
keys.kc_enable <= '1';
wait for 100 us;
keys.kc_enable <= '0';	-- time to 0:03

wait for 100 us;
keyboard_focus <= '0'; -- test with disabled keyboard_focus

wait for 100 us;
keys.kc_enable <= '1';
wait for 100 us;
keys.kc_enable <= '0';	-- time unchanged (= 0:03)

wait for 100 us;
keys.kc_enable <= '1';
wait for 100 us;
keys.kc_enable <= '0';	-- time unchanged (= 0:03)

wait for 100 us;
keyboard_focus <= '1'; -- enable keyboard_focus

wait for 100 us;
keys.kc_enable <= '1';
wait for 100 us;
keys.kc_enable <= '0';	-- time to 0:02

wait for 100 us;
keys.kc_enable <= '1';
wait for 100 us;
keys.kc_enable <= '0';	-- time to 0:01

wait for 100 us;
keys.kc_act_imp <= '1';
wait for 100 us;
keys.kc_act_imp <= '0'; -- start to count

wait for 400 us;
keys.kc_act_imp <= '1';
wait for 100 us;
keys.kc_act_imp <= '0'; -- pause - mode

wait for 800 ms;
keys.kc_act_imp <= '1';
wait for 100 us;
keys.kc_act_imp <= '0'; -- continue to count

wait for 62000 ms; -- see finish
      
     
   end process;

END;