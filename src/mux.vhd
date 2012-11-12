----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Fabian Achatz
-- 
-- Create Date:    12:50:35 11/12/2012 
-- Design Name: 
-- Module Name:    mux - Behavioral 
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


-- Entity and architecture for num_modes-1 to 1 multiplexer
entity mux is
	port (
		visible : in unsigned (3 downto 0);
		input : in character_array_1d (3 downto 0);
		output : out unsigned (7 downto 0)
		);
end entity mux;

architecture BEH of mux is
begin
	process (input, visible)
	begin
		case visible is
			when "0100" =>
			output <= input (2); -- visible (2) is date
			when "0010" =>
			output <= input (1); -- visible (1) is alarm
			when "0001" =>
			output <= input (0); -- visible (0) is countdown
			when others =>
			output <= input (3); -- forward time character if no specifikation
		end case;
	end process;
end architecture BEH;
