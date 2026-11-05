library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity keypad is
  port(
    cols     : in  std_ulogic_vector(3 downto 0);
    rows     : out std_ulogic_vector(3 downto 0);
    clk      : in  std_ulogic;

    pressed  : out std_ulogic;
    keycode  : out std_ulogic_vector(3 downto 0)
  );
end entity;

architecture behavioral of keypad is

  component ClockDivider is
    generic (
      counter : natural := 25000000
    );
    port (
      reset    : in  std_ulogic;
      clockOut : out std_ulogic;
      clk      : in  std_ulogic
    );
  end component;

  signal currentRow : integer range 0 to 3 := 0;

  signal scanRow  : std_ulogic;
  signal reset    : std_ulogic := '0';
  signal outClock : std_ulogic;

  signal lastKey    : std_ulogic_vector(3 downto 0) := (others => '0');
  signal currentKey : std_ulogic_vector(3 downto 0) := (others => '0');

  signal detected   : std_ulogic := '0';
  signal keyReleased : std_ulogic := '1';

begin

  clockInst : ClockDivider
    generic map (
      counter => 125000
    )
    port map (
      reset    => reset,
      clockOut => scanRow,
      clk      => clk
    );

  clockInst2 : ClockDivider
    generic map (
      counter => 5000
    )
    port map (
      reset    => reset,
      clockOut => outClock,
      clk      => clk
    );

  --------------------------------------------------
  -- Keypad scanning process
  --------------------------------------------------

  process(scanRow)

    variable vKey      : std_ulogic_vector(3 downto 0);
    variable vDetected : std_ulogic;

  begin

    if rising_edge(scanRow) then
      vKey := currentKey;
      vDetected := detected;

      if currentRow = 0 then
        vDetected := '0';
        vKey := "1111";
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
              vKey := "0001";
              vDetected := '1';

            when 1 =>
              vKey := "1110";
              vDetected := '1';

            when 2 =>
              vKey := "0111";
              vDetected := '1';

            when 3 =>
              vKey := "0100";
              vDetected := '1';

            when others => null;
          end case;

        when "1011" =>
          case currentRow is
            when 0 =>
              vKey := "0010";
              vDetected := '1';

            when 1 =>
              vKey := "0000";
              vDetected := '1';

            when 2 =>
              vKey := "1000";
              vDetected := '1';

            when 3 =>
              vKey := "0101";
              vDetected := '1';

            when others => null;
          end case;

        when "1101" =>
          case currentRow is
            when 0 =>
              vKey := "0011";
              vDetected := '1';

            when 2 =>
              vKey := "1001";
              vDetected := '1';

            when 3 =>
              vKey := "0110";
              vDetected := '1';

            when others => null;
          end case;
        when others => null;
      end case;

      currentKey <= vKey;
      detected <= vDetected;

      if currentRow = 3 then
        currentRow <= 0;
        if vDetected = '1' then
          if keyReleased = '1' or lastKey /= vKey then
            pressed <= '1';
            lastKey <= vKey;
            keycode <= vKey;
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