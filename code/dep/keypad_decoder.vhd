library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad_decoder is
	port(
		clk: in std_ulogic;
		keypad_input: in std_ulogic_vector(7 downto 0);
		blank: in std_ulogic;
		hex_nibble: out std_ulogic_vector(3 downto 0);
		pressed: out std_ulogic
	);
end entity;

architecture behavorial of keypad_decoder is
	signal sync1, sync2: std_ulogic_vector(7 downto 0) := (others=> '1');
	signal valid_d: std_ulogic := '0';
begin
	process(keypad_input, blank)
		variable nibble : std_ulogic_vector(3 downto 0);
		variable valid: std_ulogic;
	begin
		if rising_edge(clk) then
			sync1 <= keypad_input;
			sync2 <= sync1;

			nibble := "1111";
			valid := '1';
			case sync2 is
				-- Alle inputs zijn geinverteerd
				when "11101011" => nibble := "0000"; -- 0
				when "01110111" => nibble := "0001"; -- 1
				when "01111011" => nibble := "0010"; -- 2
				when "01111101" => nibble := "0011"; -- 3
				when "10110111" => nibble := "0100"; -- 4
				when "10111011" => nibble := "0101"; -- 5 
				when "10111101" => nibble := "0110"; -- 6
				when "11010111" => nibble := "0111"; -- 7
				when "11011011" => nibble := "1000"; -- 8
				when "11011101" => nibble := "1001"; -- 9
				when "11100111" => nibble := "1110"; -- * (resetknop, zie keypad_passcode.vhd)
				when others => valid := '0';
			end case;
			if blank = '1' then
				hex_nibble <= "1111";
				valid_d <= '0';
			else
				hex_nibble <= nibble;
				valid_d <= valid;
			end if;
			pressed <= valid_d;
		end if;
	end process;
end behavorial;