-- Simpele test die GPIO-output van keypad laat zien als LED-lampjes
library ieee;
use ieee.std_logic_1164.all;

entity keypad_test is
    port (
        GPIO_0 : in  std_ulogic_vector(7 downto 0);
        LEDR : out std_ulogic_vector(7 downto 0)
    );
end entity;

architecture rtl of keypad_test is
begin
    LEDR <= not GPIO_0;
end architecture;