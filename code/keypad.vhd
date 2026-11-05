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

  signal lastKey : std_ulogic_vector(3 downto 0) := (others => '0');
  signal currentKey : std_ulogic_vector(3 downto 0) := (others => '0');

  -- for enabling pressing 2 times the same button
  signal detected: std_ulogic := '0';
  signal keyReleased: std_ulogic := '1';

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
      if currentRow = 0 then
        detected <= '0';
        currentKey <= "1111";
      end if;

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
            when 0 => 
              currentKey <= "0001";
              detected <= '1';
            when 1 => 
              currentKey <= "1110";
              detected <= '1';
            when 2 => 
              currentKey <= "0111";
              detected <= '1';
            when 3 => 
              currentKey <= "0100";
              detected <= '1';
            when others => null;
          end case;
        when "1011" =>
          case currentRow is
            when 0 => 
              currentKey <= "0010";
              detected <= '1';
            when 1 => 
              currentKey <= "0000";
              detected <= '1';
            when 2 => 
              currentKey <= "1000";
              detected <= '1';
            when 3 => 
              currentKey <= "0101";
              detected <= '1';
            when others => null;
          end case;
        when "1101" =>
          case currentRow is
            when 0 => 
              currentKey <= "0011";
              detected <= '1';
            when 3 => 
              currentKey <= "0110";
              detected <= '1';
            when 2 => 
              currentKey <= "1001";
              detected <= '1';
            when others => null;
          end case;
        when others => null;
      end case;

      if currentRow = 3 then
        currentRow <= 0;

        if detected = '1' then
          if keyReleased = '1' or (lastKey /= currentKey) then
            pressed <= '1';
            lastKey <= currentKey;
            keycode <= currentKey;
            keyReleased <= '0';
          else
            pressed <= '0';
          end if;
        else 
          if cols = "1111" then
            keyReleased <= '1';
          end if;
          pressed <= '0';
        end if;

      else 
        currentRow <= currentRow + 1;
      end if;

    end if;
  end process;  
end architecture;