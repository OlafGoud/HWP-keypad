library ieee;
use ieee.std_logic_1164.all;
use work.keypad_pkg.all; -- Nodig voor nibble_array

entity keypad_passcode is
    port(
        reset: in std_ulogic;
        hex_nibble: in std_ulogic_vector(3 downto 0);
        pressed: in std_ulogic;
        code: out nibble_array;
        digit_count: out natural range 0 to 4;
        code_correct: out std_ulogic;
        code_incorrect: out std_ulogic;
        full: out std_ulogic -- is 'true' wanneer de ingevoerde code bestaat uit 4 getallen
    );
end entity;

architecture behavorial of keypad_passcode is
    constant CLEAR_KEY: std_ulogic_vector(3 downto 0) := "1110"; -- reset(*) knop, zie keypad_decoder.vhd
    -- De juiste code is voor nu hardgecodeerd: 1 2 3 4
    constant CORRECT_CODE: nibble_array := ("0001", "0010", "0011", "0100");

    signal code_reg : nibble_array := (others => (others => '0'));
    signal count: natural range 0 to 4 := 0;
begin
    process(pressed, reset)
    begin
        if reset = '1' then
            code_reg <= (others => (others => '0'));
            count <= 0;
        elsif rising_edge(pressed) then
            if hex_nibble = CLEAR_KEY then
                code_reg <= (others => (others => '0'));
                count <= 0;
            elsif count < 4 then
                code_reg(count) <= hex_nibble;
                count <= count + 1;
            end if;
        end if;
    end process;

    code <= code_reg;
    digit_count <= count;
    full <= '1' when count = 4 else '0';
    
    code_correct <= '1' when (count = 4 and code_reg = CORRECT_CODE) else '0';
    code_incorrect <= '1' when (count = 4 and code_reg /= CORRECT_CODE) else '0';
end architecture;