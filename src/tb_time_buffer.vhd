library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;

library work;
use work.main_pkg.all;

entity tb_time_buffer is
end entity;

architecture behavioral of tb_time_buffer is
	constant clock_divider: natural := 4;
	constant clock_period: time := 1 sec / clock_divider;

	signal uni:      universal_signals;
	signal time_in:  time_signals;
	signal time_out: time_signals;

	-- compact way to specify time info: make_time_signals("VWYYMMDDhhmmss"); (V = valid, W = dayofweek)
	function make_time_signals(input: in unsigned(55 downto 0)) return time_signals is
		variable ret: time_signals;
	begin
		ret.second    := input( 6 downto  0);
		ret.minute    := input(14 downto  8);
		ret.hour      := input(21 downto 16);
		ret.day       := input(29 downto 24);
		ret.month     := input(36 downto 32);
		ret.year      := input(47 downto 40);
		ret.dayofweek := input(50 downto 48);
		ret.valid     := input(52);
		return ret;
	end function;

	-- print out time_signals as "VWYY-MM-DDThh:mm:ss" (V = valid, W = dayofweek, T = literal T)
	procedure print_time_signals(input: in time_signals) is
		variable my_line: line;
	begin
		if input.valid = '1' then
			write(my_line, 'V');
		else
			write(my_line, ' ');
		end if;

		write(my_line, to_integer(input.dayofweek));
		write(my_line, '=');
		write(my_line, to_integer(input.year(7 downto 4)));
		write(my_line, to_integer(input.year(3 downto 0)));
		write(my_line, '-');
		write(my_line, to_integer(input.month(4 downto 4)));
		write(my_line, to_integer(input.month(3 downto 0)));
		write(my_line, '-');
		write(my_line, to_integer(input.day(5 downto 4)));
		write(my_line, to_integer(input.day(3 downto 0)));
		write(my_line, 'T');
		write(my_line, to_integer(input.hour(5 downto 4)));
		write(my_line, to_integer(input.hour(3 downto 0)));
		write(my_line, ':');
		write(my_line, to_integer(input.minute(6 downto 4)));
		write(my_line, to_integer(input.minute(3 downto 0)));
		write(my_line, ':');
		write(my_line, to_integer(input.second(6 downto 4)));
		write(my_line, to_integer(input.second(3 downto 0)));
		writeline(output, my_line);
	end procedure;

	-- just print out the current time once per second
	procedure test_time_increment(signal time_in: out time_signals; signal time_out: in time_signals; start_time: in time_signals) is
	begin
		-- send start_time to module
		time_in <= start_time;
		time_in.valid <= '1';
		wait for clock_period;
		time_in.valid <= '0';

		while true loop
			-- print current time
			print_time_signals(time_out);

			-- wait for the time_buffer to increment the time
			wait for 1 sec;
		end loop;
	end procedure;

	-- test incrementing of dates by forcing the time_buffer to incement by one day each second
	procedure test_date_increment(signal time_in: out time_signals; signal time_out: in time_signals; start_time: in time_signals) is
	begin
		-- send start_time to module
		time_in <= start_time;
		time_in.valid <= '1';
		wait for clock_period;
		time_in.valid <= '0';

		while true loop
			-- print current time
			print_time_signals(time_out);

			-- feed output as new time, with hour, minute and second set to 23:59:59
			time_in <= time_out;
			time_in.valid <= '1';
			time_in.second <= "1011001";
			time_in.minute <= "1011001";
			time_in.hour <= "100011";

			-- allow the time_buffer to register the new time and invalidate the input
			wait for clock_period;
			time_in.valid <= '0';

			-- wait for the time_buffer to increment the time
			wait for 1 sec;
		end loop;
	end procedure;

	procedure sleep_cycles(signal time_out: in time_signals; expected_time: in time_signals; cycles: in natural) is
	begin
		for i in 1 to cycles loop
			assert time_out = expected_time report "time mismatch" severity error;
			if time_out /= expected_time then
				print_time_signals(time_out);
				print_time_signals(expected_time);
			end if;
			wait for clock_period;
		end loop;
	end procedure;

	procedure test_logic(signal time_in: inout time_signals; signal time_out: in time_signals) is
		variable expected_time: time_signals;
	begin
		assert clock_divider > 1 report "clock_divider must be > 1 for this test to work" severity error;

		-- test behavior after reset
		expected_time := make_time_signals(x"06000101000000");
		sleep_cycles(time_out, expected_time, clock_divider);
		expected_time := make_time_signals(x"06000101000001");
		sleep_cycles(time_out, expected_time, clock_divider);
		expected_time := make_time_signals(x"06000101000002");
		sleep_cycles(time_out, expected_time, 1);

		-- test asynchronous clock update (an update that happens when the seconds would not normally increment)
		time_in <= make_time_signals(x"11160229235900"); -- Mon 2016-02-29T23:59:59, valid
		sleep_cycles(time_out, expected_time, 1);
		expected_time := time_in;
		time_in <= make_time_signals(x"0" & "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");
		for i in 0 to 59 loop
			expected_time.second := to_unsigned(i / 10, 3) & to_unsigned(i mod 10, 4);
			sleep_cycles(time_out, expected_time, clock_divider);
		end loop;
		expected_time := make_time_signals(x"02160301000000"); -- Tue 2016-03-01T00:00:00, invalid
		for i in 0 to 58 loop
			expected_time.second := to_unsigned(i / 10, 3) & to_unsigned(i mod 10, 4);
			sleep_cycles(time_out, expected_time, clock_divider);
		end loop;

		expected_time.second := "1011001";
		sleep_cycles(time_out, expected_time, clock_divider - 1);

		-- test synchronous clock update (an update that happens exactly at the end of a minute)
		time_in <= make_time_signals(x"14130228235900"); -- Thu 2013-02-28T23:59:59, valid
		sleep_cycles(time_out, expected_time, 1);
		expected_time := time_in;
		time_in <= make_time_signals(x"0" & "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");
		for i in 0 to 59 loop
			expected_time.second := to_unsigned(i / 10, 3) & to_unsigned(i mod 10, 4);
			sleep_cycles(time_out, expected_time, clock_divider);
		end loop;
		expected_time := make_time_signals(x"05130301000000"); -- Fri 2013-03-01T00:00:00, invalid
		for i in 0 to 59 loop
			expected_time.second := to_unsigned(i / 10, 3) & to_unsigned(i mod 10, 4);
			sleep_cycles(time_out, expected_time, clock_divider);
		end loop;
	end procedure;

begin
	time_buffer_inst: time_buffer generic map(
		clock_divider => clock_divider
	) port map(
		uni => uni,
		time_in => time_in,
		time_out => time_out
	);

	process
	begin
		uni.clk <= '0';
		wait for clock_period / 2;
		uni.clk <= '1';
		wait for clock_period / 2;
	end process;

	process
	begin
		time_in <= make_time_signals(x"0" & "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");

		uni.reset <= '1';
		wait for clock_period;
		uni.reset <= '0';

		-- test_time_increment(time_in, time_out, make_time_signals(x"16160227000000"));
		-- test_date_increment(time_in, time_out, make_time_signals(x"16160227000000"));
		test_logic(time_in, time_out);

		assert false report "all done" severity failure;

		while true loop
			wait for 1 min;
		end loop;
	end process;

	process(time_out)
	begin
		-- print_time_signals(time_out);
	end process;
end architecture;
