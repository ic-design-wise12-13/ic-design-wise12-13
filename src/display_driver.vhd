library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.main_pkg.all;

entity display_driver is
	port(
		uni:               in  universal_signals;
		characters:        in  character_array_2d(3 downto 0, 19 downto 0);
		d_en:              out std_logic;
		d_rw:              out std_logic;
		d_rs:              out std_logic;
		d_data:            out unsigned(7 downto 0)
	);
end entity;

architecture behavioral of display_driver is
	type refresh_state_t is (
		REFRESH_INIT_1,
		REFRESH_INIT_2,
		REFRESH_ADDRESS,
		REFRESH_DATA
	);
	signal refresh_state: refresh_state_t;

	type bus_state_t is (
		BUS_SETUP,
		BUS_ACTIVE,
		BUS_HOLD
	);
	signal bus_state: bus_state_t;

	signal row: std_logic;
	signal sr: character_array_1d(39 downto 0);
	signal counter: unsigned(5 downto 0);

	signal tx_done: std_logic;

begin
	-- bus FSM
	process(uni.clk)
	begin
		if rising_edge(uni.clk) then
			if uni.reset = '1' or bus_state = BUS_HOLD then
				bus_state <= BUS_SETUP;
				tx_done <= '0';
				d_en <= '0';
			elsif bus_state = BUS_SETUP then
				bus_state <= BUS_ACTIVE;
				tx_done <= '0';
				d_en <= '1';
			else
				bus_state <= BUS_HOLD;
				d_en <= '0';
				tx_done <= '1';
			end if;
		end if;
	end process;

	-- refresh FSM (includes shift register)
	process(uni.clk)
	begin
		if rising_edge(uni.clk) then
			if uni.reset = '1' then
				refresh_state <= REFRESH_INIT_1;
				row <= '0';

				d_rs <= '0';
				d_data <= x"38";

				counter <= "XXXXXX";

				for i in 0 to 39 loop
					sr(i) <= "XXXXXXXX";
				end loop;
			elsif tx_done = '1' then
				if refresh_state = REFRESH_INIT_1 then
					refresh_state <= REFRESH_INIT_2;

					d_rs <= '0';
					d_data <= x"0C";

					counter <= "XXXXXX";

					for i in 0 to 39 loop
						sr(i) <= "XXXXXXXX";
					end loop;
				elsif refresh_state = REFRESH_INIT_2 or (refresh_state = REFRESH_DATA and counter = 0) then
					refresh_state <= REFRESH_ADDRESS;
					counter <= to_unsigned(40, 6);
					row <= not row;

					for i in 0 to 19 loop
						if row = '0' then
							sr(i +  0) <= characters(0,i);
							sr(i + 20) <= characters(2,i);
						else
							sr(i +  0) <= characters(1,i);
							sr(i + 20) <= characters(3,i);
						end if;
					end loop;

					d_rs <= '0';
					d_data <= "1" & row & "000000";
				else
					refresh_state <= REFRESH_DATA;
					counter <= counter - 1;

					for i in 0 to 38 loop
						sr(i) <= sr(i + 1);
					end loop;
					sr(39) <= "XXXXXXXX";

					d_rs <= '1';
					d_data <= sr(0);
				end if;
			end if;
		end if;
	end process;

	d_rw <= '0';
end architecture;
