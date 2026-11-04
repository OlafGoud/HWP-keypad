library ieee;
use ieee.std_logic_1164.all;

entity seven_segment_driver is
    port (
        reset: in  std_ulogic;
        digitpulse: in  std_ulogic;
        HEX0: out std_ulogic_vector(6 downto 0);
        HEX1: out std_ulogic_vector(6 downto 0);
        HEX2: out std_ulogic_vector(6 downto 0);
        HEX3: out std_ulogic_vector(6 downto 0)
    );
end entity;
 
architecture behavioral of seven_segment_driver is
    constant DASH: std_ulogic_vector(6 downto 0) := "0111111";
    constant BLANK: std_ulogic_vector(6 downto 0) := "1111111";
 
    signal count: natural range 0 to 4 := 0;
begin
    process (digitpulse, reset)
    begin
        if reset = '1' then
            count <= 0;
        elsif rising_edge(digitpulse) then
            if count < 4 then
                count <= count + 1;
            end if;
        end if;
    end process;
 
    HEX0 <= DASH when count >= 1 else BLANK;
    HEX1 <= DASH when count >= 2 else BLANK;
    HEX2 <= DASH when count >= 3 else BLANK;
    HEX3 <= DASH when count >= 4 else BLANK;
end architecture;
