library STD;
use STD.textio.all;

entity bla is
end entity;

architecture a of bla is
	signal char: character := 'A';
begin
	process(char)
		variable my_line: line;
	begin
		write(my_line, char);
		writeline(output, my_line);
	end process;

	process
		variable my_line: line;
		variable char_var: character;
	begin
		readline(input, my_line);
		read(my_line, char_var);

		char <= char_var;

		wait for 1 sec;
	end process;
end architecture;
