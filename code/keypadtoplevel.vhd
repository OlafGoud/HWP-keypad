library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity keypadtoplevel is
  port(
    keypadcols: in std_ulogic_vector(3 downto 0);
  );
end entity; 