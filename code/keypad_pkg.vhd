-- Dit bestand is nodig om een array van vier hex_nibbles te maken, dit is nodig om een viercijferige code aan te maken.
library ieee;
use ieee.std_logic_1164.all;

package keypad_pkg is
    type nibble_array is array (0 to 3) of std_ulogic_vector (3 downto 0);
end package;