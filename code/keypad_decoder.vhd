library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad_decoder is
	port(
		keypad_input: in std_ulogic_vector(7 downto 0);
		blank: in std_ulogic;
		digit: out std_ulogic
	);
end entity;

architecture behavorial of keypad_decoder is
begin
	process(keypad_input, blank)
	begin
		if blank = '1' then
			digit <= "blank";
		else
			case keypad_input is
				when "00010100" => digit <= '0';
				when "10001000" => digit <= '1';
				when "10000100" => digit <= '2';
				when "10000010" => digit <= '3';
				when "01001000" => digit <= '4';
				when "01000100" => digit <= '5';
				when "01000010" => digit <= '6';
				when "00101000" => digit <= '7';
				when "00100100" => digit <= '8';
				when "00100010" => digit <= '9';
				when "00011000" => digit <= "reset";
				when others => digit <= "blank";
		end if;
	end process;
end behavorial;