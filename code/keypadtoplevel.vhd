library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity keypadtoplevel is
  port(
    keypadCols: in std_ulogic_vector(3 downto 0);
    clk: in std_ulogic;

    SEG0: out std_ulogic_vector(6 downto 0);
    SEG1: out std_ulogic_vector(6 downto 0);
    SEG2: out std_ulogic_vector(6 downto 0);
    SEG3: out std_ulogic_vector(6 downto 0);
    keypadRows: out std_ulogic_vector(3 downto 0);
    led: out std_ulogic
  );
end entity; 

architecture behavioral of keypadtoplevel is
  component ClockDivider is
    Generic (
      counter : natural := 250000000
    );
    Port (
      reset: in std_ulogic;
      clockOut: out std_ulogic;
      clk : in std_ulogic
    );
  end component;

  component keypad is
    port(
      cols: in std_ulogic_vector(3 downto 0);
      rows: out std_ulogic_vector(3 downto 0);
      clk: in std_ulogic;

      pressed: out std_ulogic;
      keycode: out std_ulogic_vector(3 downto 0)  
    );
  end component;

  component keypad_passcode is
    port(
      reset: in std_ulogic;
      hex_nibble: in std_ulogic_vector(3 downto 0);
      pressed: in std_ulogic;
      code: out nibble_array;
      digit_count: out natural range 0 to 4;
      full: out std_ulogic
    );
  end component;

  component seven_segment_driver is
    port (
      reset: in  std_ulogic;
      digitpulse: in  std_ulogic;
      HEX0: out std_ulogic_vector(6 downto 0);
      HEX1: out std_ulogic_vector(6 downto 0);
      HEX2: out std_ulogic_vector(6 downto 0);
      HEX3: out std_ulogic_vector(6 downto 0)
    );
  end component;

  component statemachine is
    port (
      codeCorrect: in std_ulogic;
      codeFault: in std_ulogic;
      codeReset: in std_ulogic;
      resetFromTime: in std_ulogic;
      clk: in std_ulogic;
      pressed: in std_ulogic;

      resetOut: out std_ulogic;
      faultCode: out std_ulogic;
      correctCode: out std_ulogic;
      ledOut: out std_ulogic;
      resetTimeOutClock: out std_ulogic
    );
  end component;

  -- signals
  signal keyPressed : std_ulogic;
  signal keyCode : std_ulogic_vector(3 downto 0);
  signal passCodeCorrectSig : std_ulogic;
  signal passCodeFaultSig : std_ulogic;
  signal passCodeResetSig : std_ulogic;
  signal digitPulsSig : std_ulogic;
  signal resetFromTimeSig : std_ulogic;
  
  -- output statemachine
  signal resetComponentsOut : std_ulogic;
  signal buzzerFault : std_ulogic;
  signal buzzerCoffect : std_ulogic;
  signal resetClock : std_ulogic;

begin

  clockdividermodule: ClockDivider generic map (
    counter => 250000000
  ) port map (
    reset => resetClock,
    clockOut => resetFromTimeSig,
    clk => clk
  );
  
  statemachinemodule : statemachine port map (
    codeCorrect => passCodeCorrectSig,
    codeFault => passCodeFaultSig,
    codeReset => passCodeResetSig,
    pressed => keyPressed
    clk
    resetFromTime => resetFromTimeSig,

    resetOut
    faultCode
    correctCode
    ledOut
    resetTimeOutClock => resetClock
  );

  passcodemodule : passcode port map (
    reset => resetComponentsOut,
    hexNibble => keyCode,
    pressed => keyPressed,

    codeCorrect => passCodeCorrectSig,
    codeFault => passCodeFaultSig,
    digitPuls => digitPulsSig,
    codeReset => passCodeResetSig
  );

  sevensegmodule : seven_segment_driver port map (
    reset => resetComponentsOut,
    digitPuls => digitPulsSig,
    HEX0 =>
    HEX1 => 
    HEX2 =>
    HEX3 =>
  );

  keypadmodule : keypad port map (
    cols =>
    rows =>
    clk =>
    pressed => keyPressed,
    keycode => keyCode
  );


  
end architecture;