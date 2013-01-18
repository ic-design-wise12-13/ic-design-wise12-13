----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Fabian Achatz
-- 
-- Create Date:    10:43:22 11/12/2012 
-- Design Name: 
-- Module Name:    Display_mux - Behavioral 
-- Project Name: 	 uhrenbaustein
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;		
use work.main_pkg.all;	

entity display_mux is
	generic(num_modes: natural := 4); 
	port(
		uni: in universal_signals;
		visible: in unsigned(num_modes - 1 downto 0);
		module_characters: in character_array_3d(num_modes - 1 downto 0, 3 downto 0, 19 downto 0);
		characters: out character_array_2d(3 downto 0, 19 downto 0)
	);
end display_mux;


architecture behavioral of display_mux is

	component mux
		port (
			visible : in unsigned (3 downto 0);
			input : in character_array_1d (num_modes -1 downto 0);
			output : out unsigned (7 downto 0)
		);
	end component;
	
begin
	loop1:for i in 3 downto 0 generate
		loop2:for j in 19 downto 0 generate
	
			-- first two lines always from time_module
			first_2nd_line: if i >= 2 generate
				characters(i, j) <= module_characters (3, i, j);
			end generate;
		
			active_alarm: if (i = 1 AND j = 19) generate
				characters (i, j) <= module_characters (1, i, j); -- star for active alarm
			end generate;
		
			all_others: if (i < 2 AND NOT (i = 1 AND j = 19)) generate -- other displaycharacters asigned by 4-to-1 multiplexers
				multiplex: mux port map (visible => visible,
									input (3) => module_characters (3, i, j),
									input (2) => module_characters (2, i, j),
									input (1) => module_characters (1, i, j),
									input (0) => module_characters (0, i, j),
									output => characters (i, j)
									);
			end generate;
		end generate;
	end generate;
end Behavioral;

