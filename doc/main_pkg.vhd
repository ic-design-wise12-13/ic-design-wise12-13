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

	-- time signals, both for buffered and unbuffered times
	type time_signals is record
		-- all signals are in BCD format!
		dayofweek:            unsigned(2 downto 0);
		day:                  unsigned(5 downto 0);
		hour:                 unsigned(5 downto 0);
		month:                unsigned(4 downto 0);
		year:                 unsigned(7 downto 0);
		minute:               unsigned(6 downto 0);
		second:               unsigned(6 downto 0);
		valid:                std_logic;
	end record;

	-- types to define arrays of characters
	type character_array_1d is array(natural range <>) of unsigned(7 downto 0);
	type character_array_2d is array(natural range <>, natural range <>) of unsigned(7 downto 0);
	type character_array_3d is array(natural range <>, natural range <>, natural range <>) of unsigned(7 downto 0);

	-- component that maintains its own clock and synchronizes it to the DCT signal if it's valid
	component time_buffer is
		port(
			uni:               in  universal_signals;
			time_in:           in  time_signals; -- input time signal from dcf77_eval (second set to 0)
			time_out:          out time_signals  -- buffered output signal
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
			d_data:            out unsigned(7 downto 0)
		);
	end component;

	component mode_fsm is
		generic(
			num_modes:         natural
		);
		port(
			uni:               in  universal_signals;
			keys:              in  keypad_signals;

			alarm_on:          in  std_logic; -- whether the alarm is ringing: force the alarm module to have keyboard focus

			keyboard_focus:    out unsigned(num_modes - 1 downto 0); -- signal to each module whether it has keyboard focus
			visible:           out unsigned(num_modes - 1 downto 0)  -- control signal to display_mux
		);
	end component;

	-- template for each mode (date, alarm, ...)
	component each_mode is
		port(
			uni:               in  universal_signals;
			keys:              in  keypad_signals;
			current_time:      in  time_signals;
			keyboard_focus:    in  std_logic;

			characters:        out character_array_2d(3 downto 0, 19 downto 0)

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
			visible:           in  unsigned(num_modes - 1 downto 0);
			module_characters: in character_array_3d(num_modes - 1 downto 0, 3 downto 0, 19 downto 0);
			characters:        out character_array_2d(3 downto 0, 19 downto 0)
		);
	end component;
end package;

-- assignment of tasks to team members:
--
--                  implementer | supervisor
-- time_buffer      Mathias     | Sophia
-- display_driver   Mathias     | Sophia
-- mode_fsm         Fabian      | Tobi
-- display_mux      Fabian      | Tobi
-- mode_time_date   Tobi        | Mathias
-- mode_alarm       Sophia      | Fabian
-- mode_countdown   Tobi        | Mathias
-- uhrenbaustein    Sophia      | Fabian
