--------------------------------------------------------------------------
-- buzzer_tb.vhd
--
-- Testbench for the buzzer component (generic: clkFreq; ports: clk,
-- pressPuls, faultPuls, correctPuls, resetPuls, buzzer).
--
-- clkFreq is overridden with 800 so the beeps are short in simulation.
-- The 1/8, 3/8 and 1/2 second durations then become:
--   short beep = 100 clock cycles, gap = 300 cycles, long beep = 400 cycles
-- (with a 10 ns clock that is 1 us, 3 us and 4 us).
--
-- Checks:
--   1. No sound while idle.
--   2. pressPuls    -> one short beep.
--   3. correctPuls  -> two short beeps with a gap between them.
--   4. faultPuls    -> one long beep.
--   5. resetPuls    -> one long beep.
--   6. A signal held high only triggers one beep (edge detection).
--   7. Simultaneous pulses follow the priority correct > fault >
--      reset code > press.
--   8. A new pulse during a beep restarts the buzzer with the new pattern.
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity buzzer_tb is
end entity;

architecture testbench of buzzer_tb is

	constant CLK_PERIOD : time    := 10 ns;
	constant CLK_FREQ   : natural := 800;

	constant SHORT_T : time := (CLK_FREQ / 8) * CLK_PERIOD;      -- 100 cycles
	constant GAP_T   : time := (CLK_FREQ / 8) * 3 * CLK_PERIOD;  -- 300 cycles
	constant LONG_T  : time := (CLK_FREQ / 2) * CLK_PERIOD;      -- 400 cycles

	component buzzer is
		generic (
			clkFreq : natural := 50000000
		);
		port (
			clk         : in  std_ulogic;
			pressPuls   : in  std_ulogic;
			faultPuls   : in  std_ulogic;
			correctPuls : in  std_ulogic;
			resetPuls   : in  std_ulogic;
			buzzer      : out std_ulogic
		);
	end component;

	signal clk         : std_ulogic := '0';
	signal pressPuls   : std_ulogic := '0';
	signal faultPuls   : std_ulogic := '0';
	signal correctPuls : std_ulogic := '0';
	signal resetPuls   : std_ulogic := '0';
	signal buzzer_out  : std_ulogic;
	signal finished    : boolean := false;

begin

	duv : buzzer
		generic map (
			clkFreq => CLK_FREQ
		)
		port map (
			clk         => clk,
			pressPuls   => pressPuls,
			faultPuls   => faultPuls,
			correctPuls => correctPuls,
			resetPuls   => resetPuls,
			buzzer      => buzzer_out
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

	-- Watchdog: abort if the test hangs (e.g. an expected beep never comes).
	watchdog : process
	begin
		wait until finished for 2 ms;
		assert finished report "Testbench timed out." severity failure;
		wait;
	end process;

	stim_process : process

		-- Give a one-clock-cycle pulse on the selected inputs, all at once.
		procedure pulse (constant p, f, c, r : in boolean) is
		begin
			wait until rising_edge(clk);
			wait for CLK_PERIOD / 4;
			if p then pressPuls   <= '1'; end if;
			if f then faultPuls   <= '1'; end if;
			if c then correctPuls <= '1'; end if;
			if r then resetPuls   <= '1'; end if;
			wait for CLK_PERIOD;
			pressPuls   <= '0';
			faultPuls   <= '0';
			correctPuls <= '0';
			resetPuls   <= '0';
		end procedure;

		-- The buzzer must stay silent for the given time.
		procedure check_silence (constant d : in time; constant tag : in string) is
		begin
			wait for d;
			assert buzzer_out = '0' and buzzer_out'last_event >= d
				report "test failed (" & tag & "): buzzer made an unexpected sound"
				severity error;
		end procedure;

		-- Expect exactly one beep of length on_t, then silence.
		procedure expect_single (constant on_t : in time; constant tag : in string) is
			variable ta, tb : time;
		begin
			wait until rising_edge(buzzer_out);
			ta := now;
			wait until falling_edge(buzzer_out);
			tb := now;
			assert tb - ta = on_t
				report "test failed (" & tag & "): beep lasted " & time'image(tb - ta) &
					", expected " & time'image(on_t)
				severity error;
			check_silence(GAP_T + SHORT_T + 5 * CLK_PERIOD, tag);
		end procedure;

		-- Expect two short beeps separated by the gap, then silence.
		procedure expect_double (constant tag : in string) is
			variable ta, tb, tc, td : time;
		begin
			wait until rising_edge(buzzer_out);
			ta := now;
			wait until falling_edge(buzzer_out);
			tb := now;
			wait until rising_edge(buzzer_out);
			tc := now;
			wait until falling_edge(buzzer_out);
			td := now;
			assert tb - ta = SHORT_T
				report "test failed (" & tag & "): first beep lasted " & time'image(tb - ta)
				severity error;
			assert tc - tb = GAP_T
				report "test failed (" & tag & "): gap lasted " & time'image(tc - tb)
				severity error;
			assert td - tc = SHORT_T
				report "test failed (" & tag & "): second beep lasted " & time'image(td - tc)
				severity error;
			check_silence(GAP_T + SHORT_T + 5 * CLK_PERIOD, tag);
		end procedure;

		variable t1, t2 : time;
	begin
		report "Testing entity buzzer.";

		----------------------------------------------------------------
		-- 1. Silence while idle (no reset input: the buzzer starts idle)
		----------------------------------------------------------------
		check_silence(10 * CLK_PERIOD, "idle");

		----------------------------------------------------------------
		-- 2. Key press: one short beep
		----------------------------------------------------------------
		pulse(true, false, false, false);
		expect_single(SHORT_T, "press");

		----------------------------------------------------------------
		-- 3. Code correct: two short beeps
		----------------------------------------------------------------
		pulse(false, false, true, false);
		expect_double("code correct");

		----------------------------------------------------------------
		-- 4. Code fault: one long beep
		----------------------------------------------------------------
		pulse(false, true, false, false);
		expect_single(LONG_T, "code fault");

		----------------------------------------------------------------
		-- 5. Reset code: one long beep
		----------------------------------------------------------------
		pulse(false, false, false, true);
		expect_single(LONG_T, "reset code");

		----------------------------------------------------------------
		-- 6. Input held high: only one beep (edge detection)
		----------------------------------------------------------------
		pressPuls <= '1';
		expect_single(SHORT_T, "press held high");
		wait for 2 * SHORT_T;
		assert buzzer_out = '0'
			report "test failed: held press beeped again" severity error;
		pressPuls <= '0';
		check_silence(10 * CLK_PERIOD, "press released");

		----------------------------------------------------------------
		-- 7. Simultaneous pulses: correct > fault > reset code > press
		----------------------------------------------------------------
		pulse(true, true, true, true);
		expect_double("all pulses: correct wins");

		pulse(true, true, false, true);
		expect_single(LONG_T, "press+fault+reset: long beep");

		pulse(true, false, false, true);
		expect_single(LONG_T, "press+reset: long beep");

		----------------------------------------------------------------
		-- 8. A new pulse during a beep restarts the buzzer
		--    Press starts a short beep; ~20 cycles later a fault pulse
		--    arrives. The buzzer must not stop after the short beep but
		--    continue as a long beep counted from the second pulse, so
		--    the total on-time is about LONG_T + 22 cycles.
		----------------------------------------------------------------
		pulse(true, false, false, false);
		wait until rising_edge(buzzer_out);
		t1 := now;
		wait for 18 * CLK_PERIOD;
		pulse(false, true, false, false);
		wait until falling_edge(buzzer_out);
		t2 := now;
		assert abs((t2 - t1) - (LONG_T + 22 * CLK_PERIOD)) <= 3 * CLK_PERIOD
			report "test failed: restart during beep, total on-time " & time'image(t2 - t1)
			severity error;
		check_silence(GAP_T + SHORT_T + 5 * CLK_PERIOD, "restart during beep");

		report "Test completed.";
		finished <= true;
		wait;
	end process;

end architecture;