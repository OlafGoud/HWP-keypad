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
  signal count : integer := 1;

begin
  process(clk, reset)
  begin
    if(reset = '1') then
      count <= 1;
      clockSig <= '0';
    elsif(rising_edge(clk)) then
      count <= count + 1;
      if (count = counter) then
        clockSig <= not clockSig;
        count <= 1;
      end if;
    end if;
    clockOut <= clockSig;
  end process;
end architecture;