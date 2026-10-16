library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad_decoder is
	port(
		keypad_input: in std_ulogic_vector(7 downto 0);
		blank: in std_ulogic;
		digit: out std_ulogic(3 downto 0)
	);
end entity;

architecture behavorial of keypad_decoder is
begin
	process(keypad_input, blank)
	begin
		if blank = '1' then
			digit <= "1111";
		else
			case keypad_input is
				when "00010100" => digit <= "0000";
				when "10001000" => digit <= "0001";
				when "10000100" => digit <= "0010";
				when "10000010" => digit <= "0011";
				when "01001000" => digit <= "0100";
				when "01000100" => digit <= "0101";
				when "01000010" => digit <= "0110";
				when "00101000" => digit <= "0111";
				when "00100100" => digit <= "1000";
				when "00100010" => digit <= "1001";
				when "00011000" => digit <= "1111"; -- Blank as reset (?)
				when others => digit <= "1111"; -- Blank
			end case;
		end if;
	end process;
end behavorial;