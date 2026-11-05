--------------------------------------------------------------------------
-- passcode_tb.vhd
--
-- Testbench for the passcode component.
-- The correct code in passcode.vhd is "0001 0010 1001 0011", i.e. the
-- keys 1, 2, 9, 3 (hex nibbles).
--
-- The outputs of passcode are one-clock-cycle pulses, so a monitor process
-- counts the clock cycles in which each output is high. Every check then
-- compares how many pulses happened since the last "mark".
--
-- Tests:
--   1. The correct code is entered      -> one codeCorrect pulse, only
--                                          after the 4th digit.
--   2. The system is reset              -> all outputs low, counter cleared.
--   3. The incorrect code is entered    -> one codeFault pulse, only after
--      (1 2 9 4, differs in the last digit). This only works as expected
--      when test 2 really cleared the digit counter.
--   4. The system is reset again and the correct code is entered
--                                       -> one codeCorrect pulse.
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity passcode_tb is
end entity;

architecture testbench of passcode_tb is

	constant CLK_PERIOD : time := 10 ns;

	component passcode is
		port (
			clk         : in  std_ulogic;
			reset       : in  std_ulogic;
			hexNibble   : in  std_ulogic_vector(3 downto 0);
			pressed     : in  std_ulogic;
			codeCorrect : out std_ulogic;
			codeFault   : out std_ulogic;
			digitPuls   : out std_ulogic;
			codeReset   : out std_ulogic
		);
	end component;

	-- Key values (hex nibbles) used in the codes.
    constant KEY_0 : std_ulogic_vector(3 downto 0) := "0000";
	constant KEY_1 : std_ulogic_vector(3 downto 0) := "0001";
	constant KEY_2 : std_ulogic_vector(3 downto 0) := "0010";
	constant KEY_3 : std_ulogic_vector(3 downto 0) := "0011";
	constant KEY_4 : std_ulogic_vector(3 downto 0) := "0100";
    constant KEY_5 : std_ulogic_vector(3 downto 0) := "0101";
    constant KEY_6 : std_ulogic_vector(3 downto 0) := "0110";
    constant KEY_7 : std_ulogic_vector(3 downto 0) := "0111";
    constant KEY_8 : std_ulogic_vector(3 downto 0) := "1000";
	constant KEY_9 : std_ulogic_vector(3 downto 0) := "1001";

	signal clk         : std_ulogic := '0';
	signal reset       : std_ulogic := '0';
	signal hexNibble   : std_ulogic_vector(3 downto 0) := "0000";
	signal pressed     : std_ulogic := '0';
	signal codeCorrect : std_ulogic;
	signal codeFault   : std_ulogic;
	signal digitPuls   : std_ulogic;
	signal codeReset   : std_ulogic;
	signal finished    : boolean := false;

	-- Number of clock cycles in which each output was high.
	signal digit_cnt   : integer := 0;
	signal correct_cnt : integer := 0;
	signal fault_cnt   : integer := 0;
	signal reset_cnt   : integer := 0;

begin

	duv : passcode
		port map (
			clk         => clk,
			reset       => reset,
			hexNibble   => hexNibble,
			pressed     => pressed,
			codeCorrect => codeCorrect,
			codeFault   => codeFault,
			digitPuls   => digitPuls,
			codeReset   => codeReset
		);

	-- Clock; stops when the test is finished so the simulation ends.
	clk_process : process
	begin
		while not finished loop
			clk <= '0';
			wait for CLK_PERIOD / 2;
			clk <= '1';
			wait for CLK_PERIOD / 2;
		end loop;
		wait;
	end process;

	-- Watchdog: abort if the test hangs.
	watchdog : process
	begin
		wait until finished for 1 ms;
		assert finished report "Testbench timed out." severity failure;
		wait;
	end process;

	-- Output monitor: count the clock cycles in which each output is high.
	monitor : process (clk)
	begin
		if rising_edge(clk) then
			if digitPuls   = '1' then digit_cnt   <= digit_cnt   + 1; end if;
			if codeCorrect = '1' then correct_cnt <= correct_cnt + 1; end if;
			if codeFault   = '1' then fault_cnt   <= fault_cnt   + 1; end if;
			if codeReset   = '1' then reset_cnt   <= reset_cnt   + 1; end if;
		end if;
	end process;

	stim_process : process
		-- Pulse counts at the last "mark".
		variable base_digit, base_correct, base_fault, base_reset : integer;

		procedure mark is
		begin
			base_digit   := digit_cnt;
			base_correct := correct_cnt;
			base_fault   := fault_cnt;
			base_reset   := reset_cnt;
		end procedure;

		-- Press and release one key. pressed is held for several clock
		-- cycles; the component must still count it as a single press.
		procedure press_key (constant nibble : in std_ulogic_vector(3 downto 0)) is
		begin
			hexNibble <= nibble;
			pressed   <= '1';
			wait for 5 * CLK_PERIOD;
			pressed   <= '0';
			wait for 5 * CLK_PERIOD;
		end procedure;

		-- Check the number of pulses since the last mark.
		procedure check (
			constant tag     : in string;
			constant digits  : in integer;
			constant correct : in integer;
			constant fault   : in integer;
			constant rst     : in integer
		) is
		begin
			assert digit_cnt - base_digit = digits
				report "test failed (" & tag & "): digitPuls pulses = " &
					integer'image(digit_cnt - base_digit) & ", expected " & integer'image(digits)
				severity error;
			assert correct_cnt - base_correct = correct
				report "test failed (" & tag & "): codeCorrect pulses = " &
					integer'image(correct_cnt - base_correct) & ", expected " & integer'image(correct)
				severity error;
			assert fault_cnt - base_fault = fault
				report "test failed (" & tag & "): codeFault pulses = " &
					integer'image(fault_cnt - base_fault) & ", expected " & integer'image(fault)
				severity error;
			assert reset_cnt - base_reset = rst
				report "test failed (" & tag & "): codeReset pulses = " &
					integer'image(reset_cnt - base_reset) & ", expected " & integer'image(rst)
				severity error;
		end procedure;

		-- Pulse the reset input.
		procedure do_reset is
		begin
			reset <= '1';
			wait for 3 * CLK_PERIOD;
			assert codeCorrect = '0' and codeFault = '0' and digitPuls = '0' and codeReset = '0'
				report "test failed: outputs not low during reset" severity error;
			reset <= '0';
			wait for 3 * CLK_PERIOD;
		end procedure;
	begin
		report "Testing entity passcode.";

		-- Idle: nothing happens without key presses.
		wait for 5 * CLK_PERIOD;
		mark;
		assert codeCorrect = '0' and codeFault = '0' and digitPuls = '0' and codeReset = '0'
			report "test failed: outputs not low while idle" severity error;

		----------------------------------------------------------------
		-- 1. The correct code is entered (1 2 9 3)
		----------------------------------------------------------------
		report "Test 1: correct code";
		press_key(KEY_1);
		press_key(KEY_2);
		press_key(KEY_9);
		check("test 1, after 3 digits", 3, 0, 0, 0);   -- no result yet
		press_key(KEY_3);
		check("test 1, correct code", 4, 1, 0, 0);

		----------------------------------------------------------------
		-- 2. The system is reset
		----------------------------------------------------------------
		report "Test 2: reset";
		do_reset;

		----------------------------------------------------------------
		-- 3. The incorrect code is entered (1 2 9 4)
		----------------------------------------------------------------
		report "Test 3: incorrect code";
		mark;
		press_key(KEY_1);
		press_key(KEY_2);
		press_key(KEY_9);
		check("test 3, after 3 digits", 3, 0, 0, 0);   -- no result yet
		press_key(KEY_4);
		check("test 3, incorrect code", 4, 0, 1, 0);

		----------------------------------------------------------------
		-- 4. The system is reset, and the correct code is entered
		----------------------------------------------------------------
		report "Test 4: reset and correct code";
		do_reset;
		mark;
		press_key(KEY_1);
		press_key(KEY_2);
		press_key(KEY_9);
		check("test 4, after 3 digits", 3, 0, 0, 0);   -- no result yet
		press_key(KEY_3);
		check("test 4, correct code", 4, 1, 0, 0);

		report "Test completed.";
		finished <= true;
		wait;
	end process;

end architecture;

-- Output:
-- # ** Note: Testing entity passcode.
-- #    Time: 0 ps  Iteration: 0  Instance: /passcode_tb
-- # ** Note: Test 1: correct code
-- #    Time: 50 ns  Iteration: 0  Instance: /passcode_tb
-- # ** Note: Test 2: reset
-- #    Time: 450 ns  Iteration: 0  Instance: /passcode_tb
-- # ** Note: Test 3: incorrect code
-- #    Time: 510 ns  Iteration: 0  Instance: /passcode_tb
-- # ** Note: Test 4: reset and correct code
-- #    Time: 910 ns  Iteration: 0  Instance: /passcode_tb
-- # ** Note: Test completed.
-- #    Time: 1370 ns  Iteration: 0  Instance: /passcode_tb