library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ClockDivider_tb is
end entity;
--let op deze 
architecture behavour of ClockDivider_tb is
component ClockDivider 
  port (
    reset: in std_ulogic;
    clockOut: out std_ulogic;
    clk : in std_ulogic
  );
end component;

  signal clk : std_ulogic := '0';
  signal reset : std_ulogic := '0';

  signal clockOut : std_ulogic;

begin

  clock: ClockDivider port map (
    reset => reset,
    clockOut => clockOut,
    clk => clk
  );

  clk_process : process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;

  process 
  begin 
    wait for 10 ns;
    reset <= '1';

  end process;


end architecture;