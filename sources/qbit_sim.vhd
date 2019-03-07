library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity qbit_sim is
end entity qbit_sim;

library work;
use work.qbit_op.all;

architecture BEHAV of qbit_sim is
  
  component qbit
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      seed        : in  std_logic_vector(31 downto 0);
      init_seed   : in  std_logic;
      operator    : in  std_logic_vector(7 downto 0);
      operator_en : in  std_logic;
      phi         : out std_logic_vector(31 downto 0);
      theta       : out std_logic_vector(31 downto 0)
      );
  end component qbit;

  signal clk         : std_logic := '0';
  signal reset       : std_logic := '0';
  signal seed        : std_logic_vector(31 downto 0) := (others => '0');
  signal init_seed   : std_logic := '0';
  signal operator    : std_logic_vector(7 downto 0) := (others => '0');
  signal operator_en : std_logic := '0';
  signal phi         : std_logic_vector(31 downto 0) := (others => '0');
  signal theta       : std_logic_vector(31 downto 0) := (others => '0');

  signal counter : unsigned(31 downto 0) := (others => '0');
  
begin

  process
  begin
    clk <= not clk;
    wait for 5ns;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      case to_integer(counter) is
        when 0 =>
          reset <= '1';
        when 10 =>
          reset <= '0';
        when 100 =>
          operator_en <= '1';
          operator <= OP_FREERUN;
        when others =>
          operator_en <= '0';
      end case;
    end if;
  end process;

  U : qbit
    port map(
      clk         => clk,
      reset       => reset,
      seed        => seed,
      init_seed   => init_seed,
      operator    => operator,
      operator_en => operator_en,
      phi         => phi,
      theta       => theta
      );
  
end BEHAV;
