library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.add;

library std;
use std.textio.all;

library work;
use work.main_pkg.all;

entity tb_mode_alarm is
end entity;


architecture behavioral of tb_mode_alarm is
  signal uni        :universal_signals;

-- wird key_focus richtig vergeben?
-- keyeingaben ignorieren wenn alarm aktiv is
-- wird das display array richtig zusammengesetzt?
-- jedes modul einmal testen


end architecture;
