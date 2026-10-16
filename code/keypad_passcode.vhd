library ieee;
use ieee.std_logic_1164.all;
use work.keypad_pkg.all; -- Nodig voor nibble_array

entity keypad_passcode is
    port(
        clk: in std_ulogic;
        reset: in std_ulogic;
        hex_nibble: in std_ulogic_vector(3 downto 0);
        pressed: in std_ulogic;
        code: out nibble_array;
        digit_count: out natural range 0 to 4;
        full: out std_ulogic
    );
end entity;

architecture behavorial of keypad_passcode is
    constant CLEAR_KEY: std_ulogic_vector(3 downto 0) := "1110"; -- reset(*) knop, zie keypad_decoder.vhd

    signal code_reg : nibble_array := (others => (others => '0'));
    signal count: natural range 0 to 4 := 0;
    signal sync1, sync2, prev: std_ulogic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            code_reg <= (others => (others => '0'));
            count <= 0;
            sync1 <= '0';
            sync2 <= '0';
            prev <= '0';
        elsif rising_edge(clk) then
            sync1 <= pressed;
            sync2 <= sync1;
            prev <= sync2;

            if sync2 = '1' and prev = '0' then 
                if hex_nibble = CLEAR_KEY then
                    code_reg <= (others => (others => '0'));
                    count <= 0;
                elsif count < 4 then
                    code_reg(count) <= hex_nibble;
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;

    code <= code_reg;
    digit_count <= count;
    full <= '1' when count = 4 else '0';
end architecture;