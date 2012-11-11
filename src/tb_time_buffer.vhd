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
	constant clock_divider: natural := 2;

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

		wait;
	end process;

	process(time_out)
		variable my_line: line;
	begin
		if time_out.valid = '1' then
			write(my_line, 'V');
		else
			write(my_line, ' ');
		end if;

		write(my_line, to_integer(time_out.dayofweek));
		write(my_line, '=');
		write(my_line, to_integer(time_out.year(7 downto 4)));
		write(my_line, to_integer(time_out.year(3 downto 0)));
		write(my_line, '-');
		write(my_line, to_integer(time_out.month(4 downto 4)));
		write(my_line, to_integer(time_out.month(3 downto 0)));
		write(my_line, '-');
		write(my_line, to_integer(time_out.day(5 downto 4)));
		write(my_line, to_integer(time_out.day(3 downto 0)));
		write(my_line, 'T');
		write(my_line, to_integer(time_out.hour(5 downto 4)));
		write(my_line, to_integer(time_out.hour(3 downto 0)));
		write(my_line, ':');
		write(my_line, to_integer(time_out.minute(6 downto 4)));
		write(my_line, to_integer(time_out.minute(3 downto 0)));
		write(my_line, ':');
		write(my_line, to_integer(time_out.second(6 downto 4)));
		write(my_line, to_integer(time_out.second(3 downto 0)));
		writeline(output, my_line);
	end process;
end architecture;
