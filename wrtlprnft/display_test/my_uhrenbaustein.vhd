library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.main_pkg.all;

entity uhrenbaustein is
	port(
		clk, reset,
		enable_1, enable_10, enable_50, enable_100,
		de_dcf_set,
		kc_up_dn, kc_enable, kc_act_long, kc_plus_imp,
		kc_minus_imp, kc_act_imp, kc_mode_imp : in std_logic := '0';
		de_dcf_dayofweek      : in std_logic_vector(2 downto 0);
		de_dcf_day            : in std_logic_vector(5 downto 0);
		de_dcf_hour           : in std_logic_vector(5 downto 0);
		de_dcf_month          : in std_logic_vector(4 downto 0);
		de_dcf_year           : in std_logic_vector(7 downto 0);
		de_dcf_minute         : in std_logic_vector(6 downto 0);

		al_on, su_on, ti_on,
		ti_beep, d_en, d_rw,
		d_rs                  : out std_logic := '0';
		d_data                : out std_logic_vector(7 downto 0));
end entity;

architecture behavioral of uhrenbaustein is
	signal uni: universal_signals;
	signal characters: character_array_2d(3 downto 0, 19 downto 0);
	signal d_data_unsigned: unsigned(7 downto 0);

	signal data: unsigned(99 downto 0);
	signal cursor: unsigned(99 downto 0);
	signal running: std_logic;

begin
	uni.clk <= clk;
	uni.reset <= reset;

	--process(clk)
	--begin
	--	if rising_edge(clk) then
	--		if reset = '1' then
	--			for row in 0 to 3 loop
	--				for col in 0 to 19 loop
	--					characters(row, col) <= to_unsigned(row * 20 + col + 32, 8);
	--				end loop;
	--			end loop;
	--		elsif enable_1 = '1' then
	--			for row in 0 to 3 loop
	--				for col in 0 to 18 loop
	--					characters(row, col) <= characters(row, col + 1);
	--				end loop;
	--			end loop;

	--			characters(0, 19) <= characters(3, 0);
	--			characters(1, 19) <= characters(0, 0);
	--			characters(2, 19) <= characters(1, 0);
	--			characters(3, 19) <= characters(2, 0);
	--		end if;
	--	end if;
	--end process;

	process(clk)
		variable count: natural;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				data <= "00000000000000000000"
				      & "00000110000000000000"
				      & "00000101000000000000"
				      & "00000100000000000000"
				      & "00000000000000000000";
				cursor <= "00000000000000000000"
				        & "00000000000000000000"
				        & "00000000000000000000"
				        & "00000000000000000000"
				        & "00000000000000000001";
				running <= '0';
			else
				if kc_act_imp = '1' then
					running <= not running;
				end if;

				if kc_enable = '1' and kc_up_dn = '1' then
					cursor <= cursor(0) & cursor(99 downto 1);
				end if;

				if kc_enable = '1' and kc_up_dn = '0' then
					cursor <= cursor(98 downto 0) & cursor(99);
				end if;

				if kc_mode_imp = '1' then
					data <= data xor cursor;
				end if;

				if enable_10 = '1' and running = '1' then
					for col in 0 to 19 loop
						for row in 0 to 4 loop
							count := 0;
							if data((col + 19) mod 20 + ((row + 4) mod 5) * 20) = '1' then count := count + 1; end if;
							if data((col +  0) mod 20 + ((row + 4) mod 5) * 20) = '1' then count := count + 1; end if;
							if data((col +  1) mod 20 + ((row + 4) mod 5) * 20) = '1' then count := count + 1; end if;
							if data((col + 19) mod 20 + ((row + 0) mod 5) * 20) = '1' then count := count + 1; end if;
							--
							if data((col +  1) mod 20 + ((row + 0) mod 5) * 20) = '1' then count := count + 1; end if;
							if data((col + 19) mod 20 + ((row + 1) mod 5) * 20) = '1' then count := count + 1; end if;
							if data((col +  0) mod 20 + ((row + 1) mod 5) * 20) = '1' then count := count + 1; end if;
							if data((col +  1) mod 20 + ((row + 1) mod 5) * 20) = '1' then count := count + 1; end if;

							data(col + 20 * row) <= '0';
							if (data(col + 20 * row) = '1' and count >= 2 and count <= 3) or count = 3 then
								data(col + 20 * row) <= '1';
							end if;
						end loop;
					end loop;
				end if;
			end if;
		end if;
	end process;

	process(data, cursor)
		variable bla: unsigned(1 downto 0);
	begin
		for col in 0 to 19 loop
			for row in 0 to 3 loop
				bla := data(col + 20 * row) & cursor(col + 20 * row);
				case bla is
					when "00" => characters(row, col) <= x"20";
					when "01" => characters(row, col) <= x"2E";
					when "10" => characters(row, col) <= x"23";
					when "11" => characters(row, col) <= x"40";
					when others => characters(row, col) <= x"20";
				end case;
			end loop;
		end loop;
	end process;

	display_driver_inst: display_driver port map(
		uni => uni,
		characters => characters,
		d_en => d_en,
		d_rw => d_rw,
		d_rs => d_rs,
		d_data => d_data_unsigned
	);

	d_data <= std_logic_vector(d_data_unsigned);

	-- replace these assignments by your own modules...
	al_on<='0';
	su_on<='1';
	ti_on<='0';
	ti_beep<='1';
	-- end replacement section
end behavioral;
