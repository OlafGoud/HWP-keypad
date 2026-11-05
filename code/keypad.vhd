library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity keypad is
  port(
    cols: in std_ulogic_vector(3 downto 0);
    rows: out std_ulogic_vector(3 downto 0);
    clk: in std_ulogic;

    pressed: out std_ulogic;
    keycode: out std_ulogic_vector(3 downto 0)  
  );
end entity;

architecture behavorial of keypad is
  component ClockDivider is
    Generic (
      counter : natural := 25000000 -- 50MHz / (100hz*4)
    );
    Port (
      reset: in std_ulogic;
      clockOut: out std_ulogic;
      clk : in std_ulogic
    );
  end component;

  signal currentRow : integer range 0 to 3 := 0;

  signal scanRow : std_ulogic;
  signal reset : std_ulogic := '0';
  signal outClock : std_ulogic;

  signal lastKey : std_ulogic_vector(3 downto 0);
  signal currentKey : std_ulogic_vector(3 downto 0);

begin
  
  clockInst : ClockDivider generic map (
    counter => 125000 -- 50MHz / (100hz*4)
  )
  port map (
    reset => reset,
    clockOut => scanRow,
    clk => clk
  );

  clockInst2 : ClockDivider generic map (
    counter => 5000
  )
  port map (
    reset => reset,
    clockOut => outClock,
    clk => clk
  );

  process(scanRow)
  begin
    if rising_edge(scanRow) then
      case currentRow is
        when 0 => rows <= "1110";
        when 1 => rows <= "1101";
        when 2 => rows <= "1011";
        when 3 => rows <= "0111";
        when others => rows <= "1111";
      end case;

      case cols is
        when "0111" => 
          case currentRow is
            when 0 => currentKey <= "0001";
            when 1 => currentKey <= "1110";
            when 2 => currentKey <= "0111";
            when 3 => currentKey <= "0100";
            when others => null;
          end case;
        when "1011" =>
          case currentRow is
            when 0 => currentKey <= "0010";
            when 1 => currentKey <= "0000";
            when 2 => currentKey <= "1000";
            when 3 => currentKey <= "0101";
            when others => null;
          end case;
        when "1101" =>
          case currentRow is
            when 0 => currentKey <= "0011";
            when 3 => currentKey <= "0110";
            when 2 => currentKey <= "1001";
            when others => null;
          end case;
        when others => null;
      end case;
      if currentRow = 3 then
        currentRow <= 0;
      else 
        currentRow <= currentRow + 1;
      end if;
    end if;
  end process;


  process(outClock)
  begin
    if rising_edge(outClock) then
      if lastKey = currentKey then
        pressed <= '0';
        keycode <= lastKey;
      else 
        pressed <= '1';
        lastKey <= currentKey;
        keycode <= lastKey;
      end if;
    end if;
  end process;
  
end architecture;