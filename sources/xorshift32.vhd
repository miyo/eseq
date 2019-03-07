library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xorshift32 is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    seed  : in  std_logic_vector(31 downto 0);
    init  : in  std_logic;
    q     : out std_logic_vector(31 downto 0)
  );
end entity xorshift32;

architecture RTL of xorshift32 is

  signal y : unsigned(31 downto 0) := to_unsigned(37590, 16) & to_unsigned(36002, 16);
  
begin

  q <= std_logic_vector(y);

  process(clk)
    variable x0 : unsigned(31 downto 0);
    variable x1 : unsigned(31 downto 0);
    variable x2 : unsigned(31 downto 0);
    variable x3 : unsigned(31 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' then
        y <= to_unsigned(37590, 16) & to_unsigned(36002, 16);
      elsif init = '1' then
        y <= unsigned(seed);
      else
        x0 := y;
	x1 := x0 xor shift_left(x0, 13);
	x2 := x1 xor shift_right(x1, 17);
	x3 := x2 xor shift_left(x2, 5);
	y <= x3;
      end if;
    end if;
  end process;

end RTL;
