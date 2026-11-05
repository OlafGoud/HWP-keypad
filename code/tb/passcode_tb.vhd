-- gen with gemini
-- make a testbench for it that checks 1x the right code and checks iwth assert that it gives correct, then reset it and try af fault code, and afther that test a right code again

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_passcode is
end entity;

architecture sim of tb_passcode is

    -- Component declaration for the passcode unit under test (UUT)
    component passcode is
        port (
            reset       : in std_ulogic;
            hexNibble   : in std_ulogic_vector(3 downto 0);
            pressed     : in std_ulogic;
            codeCorrect : out std_ulogic;
            codeFault   : out std_ulogic;
            digitPuls   : out std_ulogic;
            codeReset   : out std_ulogic
        );
    end component;

    -- Testbench signals
    signal tb_reset       : std_ulogic := '0';
    signal tb_hexNibble   : std_ulogic_vector(3 downto 0) := "0000";
    signal tb_pressed     : std_ulogic := '0';
    
    signal tb_codeCorrect : std_ulogic;
    signal tb_codeFault   : std_ulogic;
    signal tb_digitPuls   : std_ulogic;
    signal tb_codeReset   : std_ulogic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: passcode
        port map (
            reset       => tb_reset,
            hexNibble   => tb_hexNibble,
            pressed     => tb_pressed,
            codeCorrect => tb_codeCorrect,
            codeFault   => tb_codeFault,
            digitPuls   => tb_digitPuls,
            codeReset   => tb_codeReset
        );

    -- Stimulus process
    stim_proc: process
    
        -- Helper procedure to simulate pressing a key
        procedure press_key(nibble : in std_ulogic_vector(3 downto 0)) is
        begin
            tb_hexNibble <= nibble;
            wait for 20 ns;
            tb_pressed <= '1'; -- Rising edge (registers digit)
            wait for 20 ns;
            tb_pressed <= '0'; -- Falling edge (clears digit pulse)
            wait for 20 ns;
        end procedure;

    begin
        -- Initial Reset
        report "Applying initial reset...";
        tb_reset <= '1';
        tb_pressed <= '0';
        tb_hexNibble <= "0000";
        wait for 40 ns;
        tb_reset <= '0';
        wait for 40 ns;

        -------------------------------------------------------------
        -- TEST 1: Enter Correct Code ("0001", "0001", "0001", "0001")
        -------------------------------------------------------------
        report "--- TEST 1: Entering Correct Code ---";
        press_key("0001");
        press_key("0001");
        press_key("0001");
        press_key("0001"); -- 4th digit triggers evaluation

        -- Check output with assert
        assert (tb_codeCorrect = '1') 
            report "TEST 1 FAILED: codeCorrect did not assert for the correct code!" 
            severity error;
            
        if tb_codeCorrect = '1' then
            report "TEST 1 PASSED: Code correct asserted successfully.";
        end if;

        wait for 40 ns;

        -------------------------------------------------------------
        -- TEST 2: Reset the system
        -------------------------------------------------------------
        report "--- TEST 2: Resetting System ---";
        tb_reset <= '1';
        wait for 40 ns;
        tb_reset <= '0';
        wait for 40 ns;

        -------------------------------------------------------------
        -- TEST 3: Enter Fault Code ("0010", "0010", "0010", "0010")
        -------------------------------------------------------------
        report "--- TEST 3: Entering Fault Code ---";
        press_key("0010");
        press_key("0010");
        press_key("0010");
        press_key("0010"); -- 4th digit triggers evaluation

        -- Check output with assert
        assert (tb_codeFault = '1') 
            report "TEST 3 FAILED: codeFault did not assert for the wrong code!" 
            severity error;
            
        if tb_codeFault = '1' then
            report "TEST 3 PASSED: Code fault asserted successfully.";
        end if;

        wait for 40 ns;

        -------------------------------------------------------------
        -- TEST 4: Reset and enter Correct Code again
        -------------------------------------------------------------
        report "--- TEST 4: Resetting and Entering Correct Code Again ---";
        tb_reset <= '1';
        wait for 40 ns;
        tb_reset <= '0';
        wait for 40 ns;

        press_key("0001");
        press_key("0001");
        press_key("0001");
        press_key("0001");

        -- Check output with assert
        assert (tb_codeCorrect = '1') 
            report "TEST 4 FAILED: codeCorrect did not assert on the second attempt!" 
            severity error;
            
        if tb_codeCorrect = '1' then
            report "TEST 4 PASSED: Second correct code asserted successfully.";
        end if;

        report "--- ALL TESTS COMPLETED ---";
        wait; -- Stop simulation
    end process;

end architecture;