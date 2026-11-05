library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity statemachine is
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
end entity;

architecture structural of statemachine is
  type stateType is (Closed_s, Progress_s, Correct_s, Fault_s);
  signal currentState, nextState: stateType;
begin

  flipflops : process (clk)
  begin
    if rising_edge(clk) then
      currentState <= nextState;
    end if;
  end process;
  
  process(clk, codeCorrect, codeFault, codeReset, pressed, resetFromTime)
  begin
    case currentState is
      when Closed_s =>
        if pressed = '1' then
          nextState <= Progress_s;
        else
          nextState <= Closed_s;
        end if;

      when Progress_s =>
        if codeCorrect = '1' and not (codeFault = '1' or codeReset = '1') then
          nextState <= Correct_s;
        elsif codeFault = '1' and not (codeCorrect = '1' or codeReset = '1') then
          nextState <= Fault_s;
        elsif codeReset = '1' then
          nextState <= Closed_s;
        else
          nextState <= Progress_s;
        end if;

      when Correct_s =>
        if resetFromTime = '1' then
          nextState <= Closed_s;
        else
          nextState <= Correct_s;
        end if;

      when Fault_s =>
        if resetFromTime = '1' then
          nextState <= Closed_s;
        else
          nextState <= Fault_s;
        end if;
    end case;
  end process;

  process(currentState)
  begin
    case currentState is
      when Closed_s =>
        resetOut <= '1';
        faultCode <= '0';
        correctCode <= '0';
        ledOut <= '1';
        resetTimeOutClock <= '1';

      when Progress_s =>
        resetOut <= '0';
        faultCode <= '0';
        correctCode <= '0';
        ledOut <= '1';
        resetTimeOutClock <= '1';
      
        when Correct_s =>
        resetOut <= '0';
        faultCode <= '0';
        correctCode <= '1';
        ledOut <= '0';
        resetTimeOutClock <= '0';
      
        when Fault_s =>
        resetOut <= '0';
        faultCode <= '1';
        correctCode <= '0';
        ledOut <= '1';
        resetTimeOutClock <= '0';
    
    end case;
  end process;
end architecture structural;