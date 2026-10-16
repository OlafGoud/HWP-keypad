library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad_decoder is
	port(
		keypad_input: in std_ulogic_vector(7 downto 0);
		blank: in std_ulogic;
		hex_nibble: out std_ulogic_vector(3 downto 0);
		pressed: out std_ulogic
	);
end entity;

architecture behavorial of keypad_decoder is
begin
	process(keypad_input, blank)
		variable nibble : std_ulogic_vector(3 downto 0);
		variable valid: std_ulogic;
	begin
		nibble := "1111";
		valid := '1';
		case keypad_input is
			when "00010100" => nibble := "0000"; -- 0
			when "10001000" => nibble := "0001"; -- 1
			when "10000100" => nibble := "0010"; -- 2
			when "10000010" => nibble := "0011"; -- 3
			when "01001000" => nibble := "0100"; -- 4
			when "01000100" => nibble := "0101"; -- 5 
			when "01000010" => nibble := "0110"; -- 6
			when "00101000" => nibble := "0111"; -- 7
			when "00100100" => nibble := "1000"; -- 8
			when "00100010" => nibble := "1001"; -- 9
			when "00011000" => nibble := "1110"; -- * (resetknop, zie keypad_passcode.vhd)
			when others => valid := '0';
		end case;
		if blank = '1' then
			hex_nibble <= "1111";
			pressed <= '0';
		else
			hex_nibble <= nibble;
			pressed <= valid;
		end if;
	end process;
end behavorial;