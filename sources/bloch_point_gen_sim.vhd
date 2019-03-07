library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bloch_point_gen_sim is
end entity bloch_point_gen_sim;

architecture BEHAV of bloch_point_gen_sim is

  component bloch_point_gen
    port (
      clk   : in std_logic;
      reset : in std_logic;

      seed      : in std_logic_vector(31 downto 0);
      init_seed : in std_logic;

      theta : out std_logic_vector(31 downto 0);
      phi   : out std_logic_vector(31 downto 0);
      valid : out std_logic
      );
  end component bloch_point_gen;

  signal clk        : std_logic := '0';
  signal reset      : std_logic := '0';
  signal seed       : std_logic_vector(31 downto 0) := (others => '0');
  signal init_seed : std_logic := '0';
  signal theta      : std_logic_vector(31 downto 0) := (others => '0');
  signal phi        : std_logic_vector(31 downto 0) := (others => '0');
  signal valid      : std_logic := '0';

begin

  process
  begin
    clk <= not clk;
    wait for 5ns;
  end process;

  U : bloch_point_gen
    port map(
      clk       => clk,
      reset     => reset,
      seed      => seed,
      init_seed => init_seed,
      theta     => theta,
      phi       => phi,
      valid     => valid
      );

end BEHAV;
