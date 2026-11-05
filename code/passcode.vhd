library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity passcode is
  port (
    reset       : in std_ulogic;
    hexNibble   : in std_ulogic_vector(3 downto 0);
    pressed     : in std_ulogic;

    codeCorrect : out std_ulogic;
    codeFault   : out std_ulogic;
    digitPuls   : out std_ulogic;
    codeReset   : out std_ulogic
  );
end entity;

architecture behavioral of passcode is
  signal count       : integer range 0 to 4 := 0;

  signal inputdig0   : std_ulogic_vector(3 downto 0) := "0000";
  signal inputdig1   : std_ulogic_vector(3 downto 0) := "0000";
  signal inputdig2   : std_ulogic_vector(3 downto 0) := "0000";
  signal inputdig3   : std_ulogic_vector(3 downto 0) := "0000";
  
  signal combinedCode : std_ulogic_vector(15 downto 0);
  
  constant correctCode : std_ulogic_vector(15 downto 0) := "0001000100010001";
begin

  combinedCode <= inputdig0 & inputdig1 & inputdig2 & inputdig3;

  process(pressed, reset)
  begin
    if reset = '1' then
      inputdig0   <= "0000"; 
      inputdig1   <= "0000"; 
      inputdig2   <= "0000"; 
      inputdig3   <= "0000"; 
      codeReset   <= '0';
      codeCorrect <= '0';
      codeFault   <= '0';
      digitPuls   <= '0';
      count       <= 0;
    elsif rising_edge(pressed) then
      codeReset   <= '0';
      codeCorrect <= '0';
      codeFault   <= '0';
      
      if hexNibble = "1110" then
        codeReset <= '1';
        count     <= 0;
      else
        case count is
          when 0 => 
            inputdig0 <= hexNibble;
            count     <= 1;
            digitPuls <= '1';
          when 1 => 
            inputdig1 <= hexNibble;
            count     <= 2;
            digitPuls <= '1';
          when 2 => 
            inputdig2 <= hexNibble;
            count     <= 3;
            digitPuls <= '1';
          when 3 => 
            inputdig3 <= hexNibble;
            count     <= 4;
            digitPuls <= '1';
            
            -- Evaluate code on the 4th digit using the upcoming combined value
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
    elsif falling_edge(pressed) then
      digitPuls <= '0';
    end if;
  end process;
  
end architecture;