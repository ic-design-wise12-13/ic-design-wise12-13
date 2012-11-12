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
	constant clock_divider: natural := 1;

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
		wait for 50 us;
		uni.clk <= '1';
		wait for 50 us;
	end process;

	process
	begin
		time_in <= make_time_signals(x"07121111222305");

		uni.reset <= '1';
		wait for 100 us;
		uni.reset <= '0';
		wait for 100 us;

		while true loop
			time_in <= time_out;
			time_in.valid <= '1';
			time_in.second <= "1011001";
			time_in.minute <= "1011001";
			time_in.hour <= "100011";
			wait for 100 us;
			time_in.valid <= '0';
			wait for 100 us;
			print_time_signals(time_out);
		end loop;
	end process;

	process(time_out)
	begin
		-- print_time_signals(time_out);
	end process;
end architecture;
