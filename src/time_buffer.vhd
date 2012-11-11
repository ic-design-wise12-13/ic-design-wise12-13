library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.main_pkg.all;

-- see main_pkg for signal descriptions
entity time_buffer is
	generic(
		clock_divider: natural := 10000
	);
	port(
		uni:               in  universal_signals;
		time_in:           in  time_signals;
		time_out:          out time_signals
	);
end entity;

architecture behavioral of time_buffer is
	signal current_time: time_signals;
	signal current_time_inc: time_signals;
	signal counter: natural range clock_divider - 1 downto 0; -- to divide the 10 kHz clock to a period of 60 s

	signal days_in_month: unsigned(7 downto 0);

begin
	-- process that updates the clock every minute or on every received dcf signal
	process(uni.clk)
	begin
		if rising_edge(uni.clk) then
			counter <= 0;

			if uni.reset = '1' then
				-- counter already reset by default assignment
				current_time <= ("110", "000001", "000000", "00001", x"00", "0000000", "0000000", '0'); -- Sat January 1, 2000, 00:00:00, invalid
			elsif time_in.valid = '1' then
				-- register new time information and restart the minute counter
				current_time <= time_in;
			elsif counter = clock_divider - 1 then
				-- minute counter expired: increment time
				current_time <= current_time_inc;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;

	time_out <= current_time;

	-- process to compute days_in_month
	process(current_time)
		variable month: unsigned(7 downto 0);
	begin
		month := "000" & current_time.month;
		case month is
			when x"01" => days_in_month <= x"31";
			when x"03" => days_in_month <= x"31";
			when x"04" => days_in_month <= x"30";
			when x"05" => days_in_month <= x"31";
			when x"06" => days_in_month <= x"30";
			when x"07" => days_in_month <= x"31";
			when x"08" => days_in_month <= x"31";
			when x"09" => days_in_month <= x"30";
			when x"10" => days_in_month <= x"31";
			when x"11" => days_in_month <= x"30";
			when x"12" => days_in_month <= x"31";
			when x"02" => -- February is special
				-- 28 days per default
				days_in_month <= x"28";

				-- set days_in_month to 29 for years divisible by 4
				if current_time.year(4) = '1' then
					if current_time.year(3 downto 0) = x"2" or current_time.year(3 downto 0) = x"6" then
						days_in_month <= x"29";
					end if;
				elsif current_time.year(3 downto 0) = x"0" or current_time.year(3 downto 0) = x"4" or current_time.year(3 downto 0) = x"8" then
					days_in_month <= x"29";
				end if;
			when others => days_in_month <= "00UUUUUU"; -- should never happen
		end case;
	end process;

	-- process to compute current_time_inc
	process(current_time, days_in_month)
	begin
		-- don't change anything by default
		current_time_inc <= current_time;

		for i in 0 to 0 loop -- so we can break out without nesting if statements
			-- increment 1 second
			if current_time.second(3 downto 0) /= 9 then
				current_time_inc.second(3 downto 0) <= current_time.second(3 downto 0) + 1;
				exit;
			end if;
			current_time_inc.second(3 downto 0) <= x"0";

			-- increment 10 seconds
			if current_time.second(6 downto 4) /= 5 then
				current_time_inc.second(6 downto 4) <= current_time.second(6 downto 4) + 1;
				exit;
			end if;
			current_time_inc.second(6 downto 4) <= "000";

			-- increment 1 minute
			if current_time.minute(3 downto 0) /= 9 then
				current_time_inc.minute(3 downto 0) <= current_time.minute(3 downto 0) + 1;
				exit;
			end if;
			current_time_inc.minute(3 downto 0) <= x"0";

			-- increment 10 minutes
			if current_time.minute(6 downto 4) /= 5 then
				current_time_inc.minute(6 downto 4) <= current_time.minute(6 downto 4) + 1;
				exit;
			end if;
			current_time_inc.minute(6 downto 4) <= "000";

			-- increment hours (special case: reset at 23)
			if "00" & current_time.hour /= x"23" then
				if current_time.hour(3 downto 0) /= 9 then
					-- increment 1 hour
					current_time_inc.hour(3 downto 0) <= current_time.hour(3 downto 0) + 1;
				else
					-- increment 10 hours
					current_time_inc.hour(3 downto 0) <= x"0";
					current_time_inc.hour(5 downto 4) <= current_time.hour(5 downto 4) + 1;
				end if;
				exit;
			end if;
			current_time_inc.hour <= "000000";

			-- increment dayofweek
			if current_time.dayofweek /= 7 then
				current_time_inc.dayofweek <= current_time.dayofweek + 1;
			else
				current_time_inc.dayofweek <= "001";
			end if;

			-- increment day
			if current_time.day(3 downto 0) /= x"9" then
				current_time_inc.day(3 downto 0) <= current_time.day(3 downto 0) + 1;
			else
				current_time_inc.day(3 downto 0) <= x"0";
				current_time_inc.day(5 downto 4) <= current_time.day(5 downto 4) + 1;
			end if;

			if "00" & current_time.day /= days_in_month then
				exit;
			end if;

			current_time_inc.day <= "000001";

			-- increment 1 month
			if current_time.month(3 downto 0) /= x"9" then
				current_time_inc.month(3 downto 0) <= current_time.month(3 downto 0) + 1;
				exit;
			end if;
			current_time_inc.month(3 downto 0) <= x"0";

			-- increment 10 months
			current_time_inc.month(4 downto 4) <= current_time.month(4 downto 4) + 1;
			if "000" & current_time.month /= x"12" then
				exit;
			end if;
			current_time_inc.month <= "00001";

			-- increment 1 year
			if current_time.year(3 downto 0) /= x"9" then
				current_time_inc.year(3 downto 0) <= current_time.year(3 downto 0) + 1;
				exit;
			end if;
			current_time_inc.year(3 downto 0) <= x"0";

			-- increment 10 years
			if current_time.year(7 downto 4) /= x"9" then
				current_time_inc.year(7 downto 4) <= current_time.year(7 downto 4) + 1;
				exit;
			end if;
			current_time_inc.year(7 downto 4) <= x"0";

			-- happy new century! (nothing we can do here)
		end loop;
	end process;
end architecture;
