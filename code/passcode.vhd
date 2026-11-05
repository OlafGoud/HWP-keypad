library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity passcode is
  port (
    clk: in std_ulogic;
    reset: in std_ulogic;
    hexNibble: in std_ulogic_vector(3 downto 0);
    pressed: in std_ulogic;

    codeCorrect: out std_ulogic;
    codeFault: out std_ulogic;
    digitPuls: out std_ulogic;
    codeReset: out std_ulogic
  );
end entity;

architecture behavioral of passcode is
  signal count        : integer range 0 to 4 := 0;

  signal inputdig0    : std_ulogic_vector(3 downto 0) := "0000";
  signal inputdig1    : std_ulogic_vector(3 downto 0) := "0000";
  signal inputdig2    : std_ulogic_vector(3 downto 0) := "0000";
  
  constant correctCode : std_ulogic_vector(15 downto 0) := "0001001010010011";
  
  -- current and last signal from "pressed"
  signal pressedLast   : std_ulogic := '0';
  signal pressedCurrent : std_ulogic := '0';
begin

  -- rising and falling edge detection for 'pressed' signal
  process(clk, reset)
  begin
    if reset = '1' then
      pressedLast   <= '0';
      pressedCurrent <= '0';
    elsif rising_edge(clk) then
      pressedLast   <= pressed;
      pressedCurrent <= pressed and not pressedLast; -- Single-cycle pulse on button press
    end if;
  end process;

  process(clk, reset)
  begin
    if reset = '1' then
      inputdig0   <= "0000"; 
      inputdig1   <= "0000"; 
      inputdig2   <= "0000"; 
      codeReset   <= '0';
      codeCorrect <= '0';
      codeFault   <= '0';
      digitPuls   <= '0';
      count       <= 0;
    elsif rising_edge(clk) then
      codeReset   <= '0';
      codeCorrect <= '0';
      codeFault   <= '0';
      digitPuls   <= '0';
      
      if pressedCurrent = '1' then
        if hexNibble = "1110" then
          codeReset <= '1';
          count     <= 0;
        else
          digitPuls <= '1';
          case count is
            when 0 => 
              inputdig0 <= hexNibble;
              count     <= 1;
            when 1 => 
              inputdig1 <= hexNibble;
              count     <= 2;
            when 2 => 
              inputdig2 <= hexNibble;
              count     <= 3;
            when 3 => 
              count     <= 4;
              if (inputdig0 & inputdig1 & inputdig2 & hexNibble) = correctCode then
                codeCorrect <= '1';
              else
                codeFault <= '1';
              end if;
              
            when others => 
              codeFault <= '1';
              count     <= 0;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end architecture;