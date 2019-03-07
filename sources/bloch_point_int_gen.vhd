library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bloch_point_int_gen is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    seed      : in std_logic_vector(31 downto 0);
    init_seed : in std_logic;

    theta : out std_logic_vector(31 downto 0);
    phi   : out std_logic_vector(31 downto 0);
    valid : out std_logic
    );
end bloch_point_int_gen;

architecture RTL of bloch_point_int_gen is

  component xorshift32
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      seed  : in  std_logic_vector(31 downto 0);
      init  : in  std_logic;
      q     : out std_logic_vector(31 downto 0)
      );
  end component xorshift32;

  signal q       : std_logic_vector(31 downto 0) := (others => '0');
  signal q_valid : std_logic;
  signal flag : std_logic := '0';

begin

  U_RAND : xorshift32
    port map(
      clk   => clk,
      reset => reset,
      seed  => seed,
      init  => init_seed,
      q     => q
      );

  q_valid <= not reset;

  process(clk)
  begin
    if rising_edge(clk) then
      if q_valid = '1' then
        flag <= not flag;
        if flag = '0' then
          theta <= q;
        else
          phi   <= q;
        end if;
      end if;
      valid <= q_valid and flag;
    end if;
  end process;

end RTL;
