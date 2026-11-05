  /* Buzzer-component: Een buzzer gaat aan wanneer er op de keypad wordt gedrukt,*/
 /* wanneer de code goed/fout is, en waneer er op de reset-knop wordt gedrukt. */ 
/* Hiervoor zijn drie verschillende vormen van geluid bedacht.                */
library ieee;
use ieee.std_logic_1164.all;

entity buzzer is
    generic (
        clk_freq: natural := 50000000
    );
    port (
        clk: in std_ulogic;
        reset: in std_ulogic;
        press_puls: in std_ulogic;
        fault_puls: in std_ulogic;
        correct_puls: in std_ulogic;
        reset_puls: in std_ulogic;
        buzzer: out std_ulogic -- Geluid is te horen wanneer 'buzzer' hoog is.
    );
end entity;

architecture behavorial of buzzer is
    constant SHORT_BUZZ: natural := clk_freq / 8; -- Korte piep: buzzer gaat aan voor 125 milliseconden.
    constant BUZZ_GAP: natural := (clk_freq / 8) * 3; -- Tussen twee korte piepjes is er een pauze van 375 milliseconden.
    constant LONG_BUZZ: natural := clk_freq / 2;-- Lange piep: buzzer gaat aan voor 500 milliseconden.

    type state_type is (idle, buzz1, gap, buzz2);
    signal state : state_type := idle;
    signal double_buzz: std_ulogic := '0'; 
    signal timer: natural range 0 to BUZZ_GAP + LONG_BUZZ := 0;

    signal s1, s2, prev: std_ulogic_vector(3 downto 0) := (others => '0');
begin
    process (clk, reset)
        variable rise: std_ulogic_vector(3 downto 0);
    begin
        if reset = '1' then
            state <= idle;
            double_buzz <= '0';
            timer <= 0;
            s1 <= (others => '0');
            s2 <= (others => '0');
            prev <= (others => '0');
        elsif rising_edge(clk) then
            s1 <= correct_puls & fault_puls & reset_puls & press_puls;
            s2 <= s1;
            prev <= s2;
            rise := s2 and not prev;

        if rise(3) = '1' then -- code correct: 2 korte piepjes
            state <= buzz1;
            timer <= SHORT_BUZZ - 1;
            double_buzz <= '1';
        elsif rise(2) = '1' then -- code fout: 1 lange piep
            state <= buzz1;
            timer <= LONG_BUZZ - 1;
            double_buzz <= '0';
        elsif rise(1) = '1' then -- reset code: 1 lange piep
            state <= buzz1;
            timer <= LONG_BUZZ - 1;
            double_buzz <= '0';
        elsif rise(1) = '1' then -- knop ingedrukt: 1 korte piep
            state <= buzz1;
            timer <= SHORT_BUZZ - 1;
            double_buzz <= '0';
        else
            case state is
                when idle => 
                    null;
                when buzz1 =>
                    if timer = 0 then
                        if double_buzz = '1' then
                            state <= gap;
                            timer <= BUZZ_GAP - 1;
                        else
                            state <= idle;
                        end if;
                    else
                        timer <= timer - 1;
                    end if;
                when gap =>
                    if timer = 0 then
                        state <= buzz2;
                        timer <= SHORT_BUZZ - 1;
                    else
                        timer <= timer - 1;
                    end if;
                when buzz2 =>
                    if timer = 0 then
                        state <= idle;
                    else
                        timer <= timer - 1;
                    end if;
                end case;
            end if;
        end if;
    end process;

    buzzer <= '1' when (state = buzz1 or state = buzz2) else '0';
end architecture;