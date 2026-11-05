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

  -- Simulation control signal to track test steps
  signal test_step : integer := 0;

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
  stimulus_process : process
    
    -- Helper procedure to simulate pressing any key on the matrix
    procedure press_key(
      r_val     : std_ulogic_vector(3 downto 0); 
      c_val     : std_ulogic_vector(3 downto 0); 
      step_num  : integer; 
      key_desc  : string
    ) is
    begin
      report "TEST " & integer'image(step_num) & ": Pressing key '" & key_desc & "'";
      test_step <= step_num;
      cols <= "1111"; -- Release before pressing next key
      
      -- Wait until the scanner activates the target row
      loop
        wait until rising_edge(clk);
        if rows = r_val then
          cols <= c_val;
          exit;
        end if;
      end loop;
      
      -- Hold key long enough for sampling
      wait for 1.5 ms; 
    end procedure;

  begin
    -- Initial state: No keys pressed
    cols <= "1111";
    wait for 2 ms;

    ---------------------------------------------------------------------------
    -- Standard 4x4 Keypad Layout Mapping:
    -- Row 0 ("1110"): Col 0 ("1110") = '1', Col 1 ("1101") = '2', Col 2 ("1011") = '3'
    -- Row 1 ("1101"): Col 0 ("1110") = '4', Col 1 ("1101") = '5', Col 2 ("1011") = '6'
    -- Row 2 ("1011"): Col 0 ("1110") = '7', Col 1 ("1101") = '8', Col 2 ("1011") = '9'
    -- Row 3 ("0111"): Col 0 ("1110") = '*', Col 1 ("1101") = '0'
    ---------------------------------------------------------------------------

    -- Test Keys 1 to 9
    press_key("1110", "1110",  1, "1");
    press_key("1110", "1101",  2, "2");
    press_key("1110", "1011",  3, "3");
    
    press_key("1101", "1110",  4, "4");
    press_key("1101", "1101",  5, "5");
    press_key("1101", "1011",  6, "6");
    
    press_key("1011", "1110",  7, "7");
    press_key("1011", "1101",  8, "8");
    press_key("1011", "1011",  9, "9");

    -- Test Key '0' (Row 3, Col 1)
    press_key("0111", "1101", 10, "0");

    -- Test Key '*' (Row 3, Col 0 - active-low column "1110")
    press_key("0111", "1110", 11, "*");

    ---------------------------------------------------------------------------
    -- Final Cleanup & End Simulation
    ---------------------------------------------------------------------------
    report "TEST 12: Releasing key and finishing simulation";
    test_step <= 12;
    cols <= "1111";
    wait for 3 ms;

    report "Simulation completed successfully!";
    std.env.stop;
  end process;

end architecture;