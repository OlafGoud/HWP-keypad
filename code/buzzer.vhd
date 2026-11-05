  /* Buzzer-component: Een buzzer gaat aan wanneer er op de keypad wordt gedrukt, */
 /*  wanneer de code goed/fout is, en waneer er op de reset-knop wordt gedrukt.  */ 
/*   Hiervoor zijn drie verschillende vormen van geluid bedacht.                */
library ieee;
use ieee.std_logic_1164.all;

entity buzzer is
    generic (
        clkFreq: natural := 50000000
    );
    port (
        clk: in std_ulogic;
        pressPuls: in std_ulogic;
        faultPuls: in std_ulogic;
        correctPuls: in std_ulogic;
        resetPuls: in std_ulogic;
        buzzer: out std_ulogic -- Geluid is te horen wanneer 'buzzer' hoog is.
    );
end entity;

architecture behavorial of buzzer is
    constant SHORTBUZZ: natural := clkFreq / 8; -- Korte piep: buzzer gaat aan voor 125 milliseconden.
    constant BUZZGAP: natural := (clkFreq / 8) * 3; -- Tussen twee korte piepjes is er een pauze van 375 milliseconden.
    constant LONGBUZZ: natural := clkFreq / 2;-- Lange piep: buzzer gaat aan voor 500 milliseconden.

    type state_type is (idle, buzz1, gap, buzz2);
    signal state : state_type := idle;
    signal doubleBuzz: std_ulogic := '0'; 
    signal timer: natural range 0 to BUZZGAP + LONGBUZZ := 0;

    signal s1, s2, prev: std_ulogic_vector(3 downto 0) := (others => '0');
begin
    process (clk)
        variable rise: std_ulogic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            s1 <= correctPuls & faultPuls & resetPuls & pressPuls;
            s2 <= s1;
            prev <= s2;
            rise := s2 and not prev;

        if rise(3) = '1' then -- code correct: 2 korte piepjes
            state <= buzz1;
            timer <= SHORTBUZZ - 1;
            doubleBuzz <= '1';
        elsif rise(2) = '1' then -- code fout: 1 lange piep
            state <= buzz1;
            timer <= LONGBUZZ - 1;
            doubleBuzz <= '0';
        elsif rise(1) = '1' then -- reset code: 1 lange piep
            state <= buzz1;
            timer <= LONGBUZZ - 1;
            doubleBuzz <= '0';
        elsif rise(0) = '1' then -- knop ingedrukt: 1 korte piep
            state <= buzz1;
            timer <= SHORTBUZZ - 1;
            doubleBuzz <= '0';
        else
            case state is
                when idle => 
                    null;
                when buzz1 =>
                    if timer = 0 then
                        if doubleBuzz = '1' then
                            state <= gap;
                            timer <= BUZZGAP - 1;
                        else
                            state <= idle;
                        end if;
                    else
                        timer <= timer - 1;
                    end if;
                when gap =>
                    if timer = 0 then
                        state <= buzz2;
                        timer <= SHORTBUZZ - 1;
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