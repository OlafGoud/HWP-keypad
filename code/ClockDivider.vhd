library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ClockDivider is
  generic (
    counter: natural := 25000000
  );
  port (
    reset: in std_ulogic;
    clockOut: out std_ulogic;
    clk : in std_ulogic
  );
end entity;

architecture behavoural of ClockDivider is

  signal clockSig : std_ulogic := '0';
  signal count    : natural := 0;

begin
  process(clk, reset)
  begin
    if(reset = '1') then
      count <= 0;
      clockSig <= '0';
    elsif(rising_edge(clk)) then
      if (count = counter - 1) then
        count <= 0;
        clockSig <= not clockSig;
      else
          count <= count + 1;
      end if;
    end if;
  end process;
  clockOut <= clockSig;
end architecture;