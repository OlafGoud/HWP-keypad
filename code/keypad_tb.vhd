library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Keypad Testbench Entity & Architecture
--------------------------------------------------------------------------------
entity keypad_tb is
end entity;

architecture tb of keypad_tb is

  -- Component Declaration for the Keypad under test
  component keypad is
    port(
      cols    : in std_ulogic_vector(3 downto 0);
      rows    : out std_ulogic_vector(3 downto 0);
      clk     : in std_ulogic;
      pressed : out std_ulogic;
      keycode : out std_ulogic_vector(3 downto 0)  
    );
  end component;

  -- Testbench Signals
  signal clk     : std_ulogic := '0';
  signal cols    : std_ulogic_vector(3 downto 0) := "1111"; -- Default: no keys pressed (all high)
  signal rows    : std_ulogic_vector(3 downto 0);
  signal pressed : std_ulogic;
  signal keycode : std_ulogic_vector(3 downto 0);

  -- Simulation control signal to pick which key to press
  -- Format: (target_row, target_col)
  signal simulate_key : std_ulogic_vector(1 downto 0) := "00"; 
  signal test_step    : integer := 0;

  -- Clock period constant for 50 MHz (20 ns)
  constant CLK_PERIOD : time := 20 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: keypad
    port map (
      cols    => cols,
      rows    => rows,
      clk     => clk,
      pressed => pressed,
      keycode => keycode
    );

  -- 50 MHz Clock Generator Process
  clk_process : process
  begin
    clk <= '0';
    wait for CLK_PERIOD / 2;
    clk <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- Stimulus & Dynamic Key Press Emulator Process
  -- This process listens to the row scanning outputs of the keypad and 
  -- pulls the corresponding column low based on the active test case.
  stimulus_process : process
  begin
    -- Initial state: No keys pressed
    cols <= "1111";
    wait for 2 ms;

    ---------------------------------------------------------------------------
    -- Test 1: Press Key "0001" (Row 0, Col 0)
    ---------------------------------------------------------------------------
    report "TEST 1: Pressing key '0001' (Row 0, Col 0)";
    test_step <= 1;
    
    -- Wait until the scanner activates Row 0 ("1110"), then pull Col 0 ("1110") low
    loop
      wait until rising_edge(clk);
      if rows = "1110" then
        cols <= "1110"; 
        exit;
      end if;
    end loop;
    
    wait for 1.5 ms; -- Hold key long enough for outClock sampling

    ---------------------------------------------------------------------------
    -- Test 2: Release Key (Return cols to "1111")
    ---------------------------------------------------------------------------
    report "TEST 2: Releasing key";
    test_step <= 2;
    cols <= "1111";
    wait for 2 ms;

    ---------------------------------------------------------------------------
    -- Test 3: Press Key "0101" (Row 1, Col 1)
    ---------------------------------------------------------------------------
    report "TEST 3: Pressing key '0101' (Row 1, Col 1)";
    test_step <= 3;
    
    -- Wait until the scanner activates Row 1 ("1101"), then pull Col 1 ("1101") low
    loop
      wait until rising_edge(clk);
      if rows = "1101" then
        cols <= "1101";
        exit;
      end if;
    end loop;
    
    wait for 1.5 ms;

    ---------------------------------------------------------------------------
    -- Test 4: Release Key
    ---------------------------------------------------------------------------
    report "TEST 4: Releasing key";
    test_step <= 4;
    cols <= "1111";
    wait for 2 ms;

    ---------------------------------------------------------------------------
    -- Test 5: Press Key "1001" (Row 2, Col 2)
    ---------------------------------------------------------------------------
    report "TEST 5: Pressing key '1001' (Row 2, Col 2)";
    test_step <= 5;
    
    loop
      wait until rising_edge(clk);
      if rows = "1011" then
        cols <= "1011";
        exit;
      end if;
    end loop;
    
    wait for 1.5 ms;

    ---------------------------------------------------------------------------
    -- Test 6: Release and End Simulation
    ---------------------------------------------------------------------------
    report "TEST 6: Releasing key and finishing simulation";
    test_step <= 6;
    cols <= "1111";
    wait for 3 ms;

    report "Simulation completed successfully!";
    std.env.stop;
  end process;

end architecture;