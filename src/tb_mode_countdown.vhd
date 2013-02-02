--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:05:17 12/11/2012
-- Design Name:   
-- Module Name:   /home/gu95din/IC_Design/tb_Countdown_tb.vhd
-- Project Name:  IC_Design
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Countdown
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.main_pkg.all;	

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_mode_countdown IS
END tb_mode_countdown;
 
ARCHITECTURE behavior OF tb_mode_countdown IS 

   --Inputs
	signal uni: universal_signals := (others => '0');
	signal keys: keypad_signals := (others => '0');
   signal keyboard_focus : std_logic_vector(3 downto 0) := (others => '0');

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
		uni.reset <= '1';
		wait for 100 us;
		uni.reset <= '0';
		wait for 100 us;
		keyboard_focus <= "0001";		
		wait for 100 us;
		keys.kc_plus_imp <= '1';
		wait for 100 us;
		keys.kc_plus_imp <= '0';
		wait for 100 us;
		keys.kc_minus_imp <= '1';
		wait for 100 us;
		keys.kc_minus_imp <= '0';	
		
		wait for 100 us;
		keys.kc_minus_imp <= '1';
		wait for 100 us;
		keys.kc_minus_imp <= '0';	
		
		wait for 100 us;
		keyboard_focus <= "0010";		

		wait for 100 us;
		keys.kc_minus_imp <= '1';
		wait for 100 us;
		keys.kc_minus_imp <= '0';	
		
		wait for 100 us;
		keys.kc_minus_imp <= '1';
		wait for 100 us;
		keys.kc_minus_imp <= '0';	
		
		wait for 100 us;
		keyboard_focus <= "0001";	

		wait for 100 us;
		keys.kc_minus_imp <= '1';
		wait for 100 us;
		keys.kc_minus_imp <= '0';	
		
		wait for 100 us;
		keys.kc_minus_imp <= '1';
		wait for 100 us;
		keys.kc_minus_imp <= '0';			

		wait for 100 us;
		keys.kc_act_imp <= '1';
		wait for 100 us;
		keys.kc_act_imp <= '0';
		
		wait for 400 us;
		keys.kc_act_imp <= '1';
		wait for 100 us;
		keys.kc_act_imp <= '0';
		
		wait for 800 ms;
		keys.kc_act_imp <= '1';
		wait for 100 us;
		keys.kc_act_imp <= '0';


      -- insert stimulus here 

      wait;
   end process;

END;
