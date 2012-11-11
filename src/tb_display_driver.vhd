library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.main_pkg.all;

-- entity that plays the part of the display
--
-- performs timing checks, supports exactly the commands
-- that should be sent by the display driver and dumps
-- its data into an array.
entity display is
	port(
		d_en:        in  std_logic;
		d_rw:        in  std_logic;
		d_rs:        in  std_logic;
		d_data:      in  unsigned(7 downto 0);
		characters:  out character_array_2d(3 downto 0, 19 downto 0);
		initialized: out std_logic -- whether both the required initialization commands have been received
	);
end entity;

architecture behavioral of display is
	signal characters_int: character_array_2d(3 downto 0, 19 downto 0) := (
		(x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40"),
		(x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40"),
		(x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40"),
		(x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40")
	);
	signal address: unsigned(6 downto 0) := "UUUUUUU";
	signal initialized_int: unsigned(1 downto 0) := "00";

	signal en_toggle: std_logic := '0';

	constant t_c:   time := 500 ns;
	constant t_w:   time := 220 ns;
	constant t_su1: time :=  40 ns;
	constant t_h1:  time :=  10 ns;
	constant t_su2: time := 100 ns;
	constant t_h2:  time :=  20 ns;

begin
	characters <= characters_int;
	initialized <= initialized_int(1) or initialized_int(0);

	process(d_en)
	begin
		if falling_edge(d_en) then
			en_toggle <= not en_toggle;
			if d_rs = '1' then
				address <= address + 1;
				if address >= x"00" and address <= x"13" then
					characters_int(0, to_integer(address - x"00")) <= d_data;
				elsif address >= x"40" and address <= x"53" then
					characters_int(1, to_integer(address - x"40")) <= d_data;
				elsif address >= x"14" and address <= x"27" then
					characters_int(2, to_integer(address - x"14")) <= d_data;
				elsif address >= x"54" and address <= x"67" then
					characters_int(3, to_integer(address - x"54")) <= d_data;
				else
					assert false report "write to illegal address" severity error;
				end if;
			else
				if d_data = x"38" then
					initialized_int(0) <= '1';
				elsif d_data = x"0C" then
					initialized_int(1) <= '1';
				elsif d_data(7) = '1' then
					address <= d_data(6 downto 0);
				else
					assert false report "illegal command" severity error;
				end if;
			end if;
		end if;
	end process;

	process(d_rw)
	begin
		assert d_rw = '0' report "only write accesses are supported" severity error;
	end process;

	process(en_toggle)
	begin
		-- TODO: figure out how to do this properly (this test is pointless with a 10kHz clock, though)
		-- assert en_toggle'stable(t_c) report "t_c violation" severity error;
	end process;

	process(d_en)
	begin
		if rising_edge(d_en) then
			-- TODO: figure out how to do this properly (this test is pointless with a 10kHz clock, though)
			-- assert d_en'stable(t_w) report "t_w violation" severity error;
			assert d_rw'stable(t_w) report "t_su1 violation on d_rw" severity error;
			assert d_rs'stable(t_w) report "t_su1 violation on d_rs" severity error;
		end if;
	end process;

	process(d_en'delayed(t_h1))
	begin
		if falling_edge(d_en'delayed(t_h1)) then
			assert d_rw'stable(t_h1) report "t_h1 violation on d_rw" severity error;
			assert d_rs'stable(t_h1) report "t_h1 violation on d_rs" severity error;
		end if;
	end process;

	process(d_en'delayed(t_h2))
	begin
		if falling_edge(d_en'delayed(t_h2)) then
			assert d_data'stable(t_su2 + t_h2) report "t_su2 or t_h2 violation" severity error;
		end if;
	end process;
end architecture;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;

library work;
use work.main_pkg.all;

entity tb_display_driver is
end entity;

architecture behavioral of tb_display_driver is
	signal uni:            universal_signals;
	signal characters_in:  character_array_2d(3 downto 0, 19 downto 0);
	signal characters_out: character_array_2d(3 downto 0, 19 downto 0);
	signal d_en:           std_logic;
	signal d_rw:           std_logic;
	signal d_rs:           std_logic;
	signal d_data:         unsigned(7 downto 0);
	signal initialized:    std_logic;

	signal display_content_in: string(1 to 80);

	component display is
		port(
			d_en:        in  std_logic;
			d_rw:        in  std_logic;
			d_rs:        in  std_logic;
			d_data:      in  unsigned(7 downto 0);
			characters:  out character_array_2d(3 downto 0, 19 downto 0);
			initialized: out std_logic
		);
	end component;

begin
	display_driver_inst: display_driver port map(
		uni => uni,
		characters => characters_in,
		d_en => d_en,
		d_rw => d_rw,
		d_rs => d_rs,
		d_data => d_data
	);
	display_inst: display port map(
		d_en => d_en,
		d_rw => d_rw,
		d_rs => d_rs,
		d_data => d_data,
		characters => characters_out,
		initialized => initialized
	);

	display_content_in <= "abcdefghijklmnopqrst"
	                    & "ABCDEFGHIJKLMNOPQRST"
	                    & "0123456789uvwxyzUVWX"
	                    & "YZ,;.:-_#'+*@ <>|()!";

	process
	begin
		uni.clk <= '0';
		wait for 50 us;
		uni.clk <= '1';
		wait for 50 us;
	end process;

	process
	begin
		uni.reset <= '1';
		wait for 100 us;
		uni.reset <= '0';

		wait for 60 min;
	end process;

	process(display_content_in)
	begin
		for row in 0 to 3 loop
			for col in 0 to 19 loop
				characters_in(row, col) <= to_unsigned(character'pos(display_content_in(20*row + col + 1)), 8);
			end loop;
		end loop;
	end process;

	process(characters_out)
		variable my_line: line;
	begin
		if initialized = '1' then
			for row in 0 to 3 loop
				for col in 0 to 19 loop
					write(my_line, "" & character'val(to_integer(characters_out(row, col))));
				end loop;
				writeline(output, my_line);
			end loop;
		end if;
	end process;

end architecture;
