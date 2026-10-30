--- AI generated testbensh
--- promt: make a testbensh for this vhdl code (code added)
--- and i added the satemachine diagram
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_statemachine is
end entity;

architecture simulation of tb_statemachine is

    -- Input signals
    signal codeCorrect  : std_ulogic := '0';
    signal codeFault    : std_ulogic := '0';
    signal codeReset    : std_ulogic := '0';
    signal resetFromTime: std_ulogic := '0';
    signal clk          : std_ulogic := '0';
    signal pressed      : std_ulogic := '0';

    -- Output signals
    signal resetOut     : std_ulogic;
    signal faultCode    : std_ulogic;
    signal correctCode  : std_ulogic;
    signal ledOut       : std_ulogic;
    signal resetClock   : std_ulogic;

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: entity work.statemachine
        port map (
            codeCorrect   => codeCorrect,
            codeFault     => codeFault,
            codeReset     => codeReset,
            resetFromTime => resetFromTime,
            clk           => clk,
            pressed       => pressed,

            resetOut      => resetOut,
            faultCode     => faultCode,
            correctCode   => correctCode,
            ledOut        => ledOut,
            resetClock    => resetClock
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test process
    stimulus : process

        -- Wait for clock edge and check outputs
        procedure check_state(
            constant expected_resetOut    : std_ulogic;
            constant expected_faultCode   : std_ulogic;
            constant expected_correctCode : std_ulogic;
            constant expected_ledOut      : std_ulogic;
            constant expected_resetClock  : std_ulogic;
            constant state_name           : string
        ) is
        begin
            wait until rising_edge(clk);
            wait for 1 ns;

            assert resetOut = expected_resetOut
                report "resetOut error in " & state_name
                severity error;

            assert faultCode = expected_faultCode
                report "faultCode error in " & state_name
                severity error;

            assert correctCode = expected_correctCode
                report "correctCode error in " & state_name
                severity error;

            assert ledOut = expected_ledOut
                report "ledOut error in " & state_name
                severity error;

            assert resetClock = expected_resetClock
                report "resetClock error in " & state_name
                severity error;

            report "Passed: " & state_name
                severity note;
        end procedure;

    begin

        ------------------------------------------------
        -- TEST 1: CLOSED STATE
        ------------------------------------------------

        pressed       <= '0';
        codeCorrect   <= '0';
        codeFault     <= '0';
        codeReset     <= '0';
        resetFromTime <= '0';

        check_state('1', '0', '0', '1', '1', "Closed_s initial");

        ------------------------------------------------
        -- TEST 2: CLOSED -> PROGRESS
        ------------------------------------------------

        pressed <= '1';

        check_state('0', '0', '0', '1', '1', "Progress_s");

        ------------------------------------------------
        -- TEST 3: PROGRESS -> PROGRESS
        -- No correct or fault code
        ------------------------------------------------

        pressed <= '0';

        check_state('0', '0', '0', '1', '1', "Progress_s hold");

        ------------------------------------------------
        -- TEST 4: PROGRESS -> CORRECT
        ------------------------------------------------

        codeCorrect <= '1';

        check_state('0', '0', '1', '0', '0', "Correct_s");

        ------------------------------------------------
        -- TEST 5: CORRECT -> CORRECT
        -- Timer has not expired
        ------------------------------------------------

        resetFromTime <= '0';

        check_state('0', '0', '1', '0', '0', "Correct_s hold");

        ------------------------------------------------
        -- TEST 6: CORRECT -> CLOSED
        -- Timer expires
        ------------------------------------------------

        codeCorrect   <= '0';
        resetFromTime <= '1';

        check_state('1', '0', '0', '1', '1', "Correct to Closed");

        ------------------------------------------------
        -- TEST 7: CLOSED -> PROGRESS
        ------------------------------------------------

        resetFromTime <= '0';
        pressed       <= '1';

        check_state('0', '0', '0', '1', '1', "Progress_s again");

        ------------------------------------------------
        -- TEST 8: PROGRESS -> FAULT
        ------------------------------------------------

        pressed   <= '0';
        codeFault <= '1';

        check_state('0', '1', '0', '1', '0', "Fault_s");

        ------------------------------------------------
        -- TEST 9: FAULT -> FAULT
        -- Timer has not expired
        ------------------------------------------------

        codeFault <= '0';

        check_state('0', '1', '0', '1', '0', "Fault_s hold");

        ------------------------------------------------
        -- TEST 10: FAULT -> CLOSED
        -- Timer expires
        ------------------------------------------------

        resetFromTime <= '1';

        check_state('1', '0', '0', '1', '1', "Fault to Closed");

        ------------------------------------------------
        -- TEST 11: CLOSED -> PROGRESS
        ------------------------------------------------

        resetFromTime <= '0';
        pressed       <= '1';

        check_state('0', '0', '0', '1', '1', "Progress_s reset test");

        ------------------------------------------------
        -- TEST 12: PROGRESS -> CLOSED
        -- Reset button activated
        ------------------------------------------------

        pressed   <= '0';
        codeReset <= '1';

        check_state('1', '0', '0', '1', '1', "Progress to Closed");

        ------------------------------------------------
        -- TEST 13: CLOSED -> PROGRESS
        ------------------------------------------------

        codeReset <= '0';
        pressed   <= '1';

        check_state('0', '0', '0', '1', '1', "Progress_s final");

        ------------------------------------------------
        -- TEST 14: BOTH CORRECT AND FAULT
        -- Machine should remain in Progress
        ------------------------------------------------

        pressed     <= '0';
        codeCorrect <= '1';
        codeFault   <= '1';

        check_state('0', '0', '0', '1', '1', "Both codes activated");

        ------------------------------------------------
        -- TEST 15: CORRECT AND RESET SIMULTANEOUSLY
        -- Reset should send machine to Closed
        ------------------------------------------------

        codeReset <= '1';

        check_state('1', '0', '0', '1', '1', "Correct and Reset");

        ------------------------------------------------
        -- TEST 16: FAULT AND RESET SIMULTANEOUSLY
        ------------------------------------------------

        pressed     <= '1';
        codeCorrect <= '0';
        codeFault   <= '0';
        codeReset   <= '0';

        check_state('0', '0', '0', '1', '1', "Progress before reset");

        pressed   <= '0';
        codeFault <= '1';
        codeReset <= '1';

        check_state('1', '0', '0', '1', '1', "Fault and Reset");

        ------------------------------------------------
        -- END OF SIMULATION
        ------------------------------------------------

        report "ALL TESTS COMPLETED SUCCESSFULLY!"
            severity note;

        std.env.stop;
        wait;

    end process;

end architecture simulation;
-- run -all
-- # ** Note: Passed: Closed_s initial
-- #    Time: 6 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Progress_s
-- #    Time: 16 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Progress_s hold
-- #    Time: 26 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Correct_s
-- #    Time: 36 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Correct_s hold
-- #    Time: 46 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Correct to Closed
-- #    Time: 56 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Progress_s again
-- #    Time: 66 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Fault_s
-- #    Time: 76 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Fault_s hold
-- #    Time: 86 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Fault to Closed
-- #    Time: 96 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Progress_s reset test
-- #    Time: 106 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Progress to Closed
-- #    Time: 116 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Progress_s final
-- #    Time: 126 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Both codes activated
-- #    Time: 136 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Correct and Reset
-- #    Time: 146 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Progress before reset
-- #    Time: 156 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: Passed: Fault and Reset
-- #    Time: 166 ns  Iteration: 0  Instance: /tb_statemachine
-- # ** Note: ALL TESTS COMPLETED SUCCESSFULLY!
-- #    Time: 166 ns  Iteration: 0  Instance: /tb_statemachine