library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xorshift32_sim is
end xorshift32_sim;

architecture BEHAV of xorshift32_sim is
  
  component xorshift32
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      seed  : in  std_logic_vector(31 downto 0);
      init  : in  std_logic;
      q     : out std_logic_vector(31 downto 0)
      );
  end component xorshift32;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  signal seed  : std_logic_vector(31 downto 0) := (others => '0');
  signal init  : std_logic := '0';
  signal q     : std_logic_vector(31 downto 0) := (others => '0');
  
begin

  process
  begin
    clk <= not clk;
    wait for 5ns;
  end process;

  U: xorshift32
    port map(
      clk   => clk,
      reset => reset,
      seed  => seed,
      init  => init,
      q     => q
      );
  
end BEHAV;
