library ieee;
use ieee.std_logic_1164.all;

entity ClockDivider_tb is
end entity;

architecture simulation of ClockDivider_tb is

    -- Testbench signals
    signal reset    : std_ulogic := '0';
    signal clk      : std_ulogic := '0';
    signal clockOut : std_ulogic;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    --------------------------------------------------------------------
    -- Device Under Test
    --------------------------------------------------------------------
    DUT : entity work.ClockDivider(behavoural)
        generic map (
            counter => 4
        )
        port map (
            reset    => reset,
            clockOut => clockOut,
            clk      => clk
        );


    --------------------------------------------------------------------
    -- Generate the input clock
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;

            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;


    --------------------------------------------------------------------
    -- Test process
    --------------------------------------------------------------------
    stim_proc : process
    begin

        ---------------------------------------------------------------
        -- Test reset
        ---------------------------------------------------------------
        reset <= '1';
        wait for 15 ns;

        assert clockOut = '0'
            report "Test failed: clockOut should be 0 during reset"
            severity error;

        reset <= '0';


        ---------------------------------------------------------------
        -- Wait for the first clock division cycle
        --
        -- With counter = 4, clockOut should toggle after 4 input
        -- clock rising edges.
        ---------------------------------------------------------------
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        wait for 1 ns;

        assert clockOut = '1'
            report "Test failed: clockOut should toggle to 1"
            severity error;


        ---------------------------------------------------------------
        -- Wait for the second division cycle
        ---------------------------------------------------------------
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        wait for 1 ns;

        assert clockOut = '0'
            report "Test failed: clockOut should toggle back to 0"
            severity error;


        ---------------------------------------------------------------
        -- Test reset while the clock divider is running
        ---------------------------------------------------------------
        reset <= '1';
        wait for 1 ns;

        assert clockOut = '0'
            report "Test failed: reset should set clockOut to 0"
            severity error;

        reset <= '0';


        report "All ClockDivider tests completed successfully!"
            severity note;

        wait;
    end process;

end architecture;

-- Output:
-- # ** Note: All ClockDivider tests completed successfully!
-- #    Time: 87 ns  Iteration: 0  Instance: /clockdivider_tb