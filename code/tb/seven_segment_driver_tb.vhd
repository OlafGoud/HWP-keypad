library ieee;
use ieee.std_logic_1164.all;

entity seven_segment_driver_tb is
end entity;

architecture simulation of seven_segment_driver_tb is

    -- Signals connected to the DUT
    signal reset     : std_ulogic := '0';
    signal digitPuls : std_ulogic := '0';

    signal HEX0 : std_ulogic_vector(6 downto 0);
    signal HEX1 : std_ulogic_vector(6 downto 0);
    signal HEX2 : std_ulogic_vector(6 downto 0);
    signal HEX3 : std_ulogic_vector(6 downto 0);

    -- Expected seven-segment values
    constant DASH  : std_ulogic_vector(6 downto 0) := "0111111";
    constant BLANK : std_ulogic_vector(6 downto 0) := "1111111";

begin

    -- Instantiate the Device Under Test (DUT)
    DUT: entity work.seven_segment_driver(behavioral)
        port map (
            reset     => reset,
            digitPuls => digitPuls,
            HEX0      => HEX0,
            HEX1      => HEX1,
            HEX2      => HEX2,
            HEX3      => HEX3
        );


    -- Test process
    stim_proc: process
    begin

        ----------------------------------------------------------------
        -- Test 1: Reset
        ----------------------------------------------------------------
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        wait for 10 ns;

        assert HEX0 = BLANK and HEX1 = BLANK and
               HEX2 = BLANK and HEX3 = BLANK
            report "Test failed: Displays should be blank after reset"
            severity error;


        ----------------------------------------------------------------
        -- Test 2: First pulse
        ----------------------------------------------------------------
        digitPuls <= '1';
        wait for 10 ns;
        digitPuls <= '0';
        wait for 10 ns;

        assert HEX0 = DASH and HEX1 = BLANK and
               HEX2 = BLANK and HEX3 = BLANK
            report "Test failed: HEX0 should show DASH after first pulse"
            severity error;


        ----------------------------------------------------------------
        -- Test 3: Second pulse
        ----------------------------------------------------------------
        digitPuls <= '1';
        wait for 10 ns;
        digitPuls <= '0';
        wait for 10 ns;

        assert HEX0 = DASH and HEX1 = DASH and
               HEX2 = BLANK and HEX3 = BLANK
            report "Test failed: HEX0 and HEX1 should show DASH"
            severity error;


        ----------------------------------------------------------------
        -- Test 4: Third pulse
        ----------------------------------------------------------------
        digitPuls <= '1';
        wait for 10 ns;
        digitPuls <= '0';
        wait for 10 ns;

        assert HEX0 = DASH and HEX1 = DASH and
               HEX2 = DASH and HEX3 = BLANK
            report "Test failed: HEX0, HEX1 and HEX2 should show DASH"
            severity error;


        ----------------------------------------------------------------
        -- Test 5: Fourth pulse
        ----------------------------------------------------------------
        digitPuls <= '1';
        wait for 10 ns;
        digitPuls <= '0';
        wait for 10 ns;

        assert HEX0 = DASH and HEX1 = DASH and
               HEX2 = DASH and HEX3 = DASH
            report "Test failed: All displays should show DASH"
            severity error;


        ----------------------------------------------------------------
        -- Test 6: Extra pulse should not increase count beyond 4
        ----------------------------------------------------------------
        digitPuls <= '1';
        wait for 10 ns;
        digitPuls <= '0';
        wait for 10 ns;

        assert HEX0 = DASH and HEX1 = DASH and
               HEX2 = DASH and HEX3 = DASH
            report "Test failed: Count should not exceed 4"
            severity error;


        report "All tests completed successfully!" severity note;

        wait;
    end process;

end architecture;

-- Output:
-- # ** Note: All tests completed successfully!
-- #    Time: 120 ns  Iteration: 0  Instance: /seven_segment_driver_tb