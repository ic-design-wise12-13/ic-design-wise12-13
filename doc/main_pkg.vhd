library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package main_pkg is
	-- signals that are routed to every module
	type universal_signals is record
		clk:                  std_logic;
		reset:                std_logic;
		enable_1:             std_logic;
		enable_10:            std_logic;
		enable_50:            std_logic;
		enable_100:           std_logic;
	end record;

	-- keypad signals, as available at the top-level module
	type keypad_signals is record
		kc_up_dn:             std_logic;
		kc_enable:            std_logic;
		kc_act_long:          std_logic;
		kc_plus_imp:          std_logic;
		kc_minus_imp:         std_logic;
		kc_act_imp:           std_logic;
		kc_mode_imp:          std_logic;
	end record;

	-- buffered time signals (including seconds)
	type time_signals is record
		dayofweek:            unsigned(2 downto 0);
		day:                  unsigned(5 downto 0);
		hour:                 unsigned(5 downto 0);
		month:                unsigned(4 downto 0);
		year:                 unsigned(7 downto 0);
		minute:               unsigned(6 downto 0);
		valid:                std_logic;
	end record;

	-- types to define arrays of characters
	type character_array_2d is array(natural range <>, natural range <>) of unsigned(7 downto 0);
	type character_array_3d is array(natural range <>, natural range <>, natural range <>) of unsigned(7 downto 0);

	-- component that maintains its own clock and synchronizes it to the DCT signal if it's valid
	component time_buffer is
		port(
			uni:               in  universal_signals;
			time_in:           in  time_signals;
			time_out:          out time_signals
		);
	end component;

	-- constantly refreshes the display with characters. also handles display initialization after reset
	component display_driver is
		port(
			uni:               in  universal_signals;
			characters:        in  character_array_2d(3 downto 0, 19 downto 0);
			d_en:              out std_logic;
			d_rw:              out std_logic;
			d_rs:              out std_logic;
			d_data:            out std_logic_vector(7 downto 0)
		);
	end component;

	component mode_fsm is
		generic(
			num_modes:         natural
		);
		port(
			uni:               in  universal_signals;
			keys:              in  keypad_signals;

			visible:           out std_logic_vector(num_modes - 1 downto 0); -- signal to each module whether it has keyboard focus and is visible (one-in-n)
			return_to_default: in  std_logic_vector(num_modes - 1 downto 0); -- signal from each module, whether the default state should be activated instantly
			modified:          in  std_logic_vector(num_modes - 1 downto 0)  -- signal from each module, whether the next mode key press should return to the default state
		);
	end component;

	-- template for each mode (date, alarm, ...)
	component each_mode is
		port(
			uni:               in  universal_signals;
			keys:              in  keypad_signals;
			current_time:      in  time_signals;
			alarm:             in  std_logic; -- whether the alarm is ringing: ignore keypresses except for the alarm module itself

			characters:        out character_array_2d(3 downto 0, 19 downto 0);

			keyboard_focus:    in  std_logic;
			return_to_default: out std_logic;
			modified:          out std_logic

			-- plus module-specific outputs
		);
	end component;

	-- modules:
	--  - time
	--  - date
	--  - alarm
	--  - countdown

	component display_mux is
		generic(
			num_modes:         natural
		);
		port(
			uni:               in  universal_signals;
			visible:           in  std_logic_vector(num_modes - 1 downto 0);
			module_characters: out character_array_3d(num_modes - 1 downto 0, 3 downto 0, 19 downto 0);
			characters:        out character_array_2d(3 downto 0, 19 downto 0)
		);
	end component;
end package;

-- assignment of tasks to team members:
--
--                implementer | supervisor
-- time_buffer    Mathias     | Sophia
-- display_driver Mathias     | Sophia
-- mode_fsm       Fabian      | Max
-- display_mux    Fabian      | Max
-- mode_time      Max         | Tobi
-- mode_date      Tobi        | Mathias
-- mode_alarm     Sophia      | Fabian
-- mode_countdown Tobi        | Mathias
-- uhrenbaustein  Sophia      | Fabian
