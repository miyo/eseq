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
      operator    : in  std_logic_vector(23 downto 0);
      operator_en : in  std_logic;

      csel_0 : out std_logic_vector(7 downto 0);
      cin_0  : in  std_logic_vector(63 downto 0);
      csel_1 : out std_logic_vector(7 downto 0);
      cin_1  : in  std_logic_vector(63 downto 0);

      phi         : out std_logic_vector(31 downto 0);
      theta       : out std_logic_vector(31 downto 0)
      );
  end component qbit;

  signal clk         : std_logic := '0';
  signal reset       : std_logic := '0';
  signal init_seed   : std_logic := '0';

  signal counter : unsigned(31 downto 0) := (others => '0');

  type array64 is array(3 downto 0) of std_logic_vector(63 downto 0);
  type array32 is array(3 downto 0) of std_logic_vector(31 downto 0);
  type array24 is array(3 downto 0) of std_logic_vector(23 downto 0);
  type array8 is array(3 downto 0) of std_logic_vector(7 downto 0);
  type array1 is array(3 downto 0) of std_logic;

  signal seed        : array32 := (others => (others => '0'));
  signal operator    : array24 := (others => (others => '0'));
  signal operator_en : array1  := (others => '0');
  signal csel_0      : array8  := (others => (others => '0'));
  signal cin_0       : array64 := (others => (others => '0'));
  signal csel_1      : array8  := (others => (others => '0'));
  signal cin_1       : array64 := (others => (others => '0'));
  signal phi         : array32 := (others => (others => '0'));
  signal theta       : array32 := (others => (others => '0'));

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
          reset       <= '1';
          init_seed   <= '0';
          operator_en <= (others => '0');
        when 10 =>
          reset <= '0';
        when 20 =>
          init_seed <= '1';
          seed(0)   <= std_logic_vector(to_unsigned(37590, 16) & to_unsigned(36002, 16));
          seed(1)   <= std_logic_vector(to_unsigned(37591, 16) & to_unsigned(36003, 16));
          seed(2)   <= std_logic_vector(to_unsigned(37592, 16) & to_unsigned(36004, 16));
          seed(3)   <= std_logic_vector(to_unsigned(37593, 16) & to_unsigned(36005, 16));          
        when 100 =>
          operator_en <= (others => '1');
          operator(0) <= X"0000" & OP_CLR;
          operator(1) <= X"0000" & OP_CLR;
          operator(2) <= X"0000" & OP_CLR;
          operator(3) <= X"0000" & OP_CLR;
        when 101 =>
          operator_en <= "0011";
          operator(0) <= X"0000" & OP_X; -- theta = 180
          operator(1) <= X"0000" & OP_X; -- theta = 180
        when 102 =>
          operator_en <= "0100";
          operator(2) <= X"0000" & OP_CNOT;
        when 103 =>
          operator_en <= "0100";
          operator(2) <= X"0001" & OP_CNOT;
        when 104 =>
          operator_en <= "1000";
          operator(3) <= X"0001" & OP_CCX;
        when 105 =>
          operator_en <= "0100";
          operator(0) <= X"0000" & OP_MEASURE;
          operator(1) <= X"0000" & OP_MEASURE;
          operator(2) <= X"0000" & OP_MEASURE;
          operator(3) <= X"0000" & OP_MEASURE;
        when 200 =>
          operator_en <= (others => '1');
          operator(0) <= X"0000" & OP_CLR;
          operator(1) <= X"0000" & OP_CLR;
          operator(2) <= X"0000" & OP_CLR;
          operator(3) <= X"0000" & OP_CLR;
        when 201 =>
          operator_en <= "0011";
          operator(0) <= X"0000" & OP_H;
          operator(1) <= X"0000" & OP_H;
        when 202 =>
          operator_en <= "0100";
          operator(2) <= X"0000" & OP_CNOT;
        when 203 =>
          operator_en <= "0100";
          operator(2) <= X"0001" & OP_CNOT;
        when 204 =>
          operator_en <= "1000";
          operator(3) <= X"0001" & OP_CCX;
        when 205 =>
          operator_en <= "0100";
          operator(0) <= X"0000" & OP_MEASURE;
          operator(1) <= X"0000" & OP_MEASURE;
          operator(2) <= X"0000" & OP_MEASURE;
          operator(3) <= X"0000" & OP_MEASURE;
        when others =>
          init_seed   <= '0';
          operator_en <= (others => '0');
      end case;
    end if;
  end process;

  GEN_Q : for i in 0 to 3 generate
    Q : qbit
      port map(
        clk         => clk,
        reset       => reset,
        seed        => seed(i),
        init_seed   => init_seed,
        operator    => operator(i),
        operator_en => operator_en(i),
        csel_0      => csel_0(i),
        cin_0       => cin_0(i),
        csel_1      => csel_1(i),
        cin_1       => cin_1(i),
        phi         => phi(i),
        theta       => theta(i)
        );
    cin_0(i) <= phi(0) & theta(0) when csel_0(i) = X"00" else
                phi(1) & theta(1) when csel_0(i) = X"01" else
                phi(2) & theta(2) when csel_0(i) = X"02" else
                phi(3) & theta(3) when csel_0(i) = X"03" else
                (others => '0');
    cin_1(i) <= phi(0) & theta(0) when csel_0(i) = X"00" else
                phi(1) & theta(1) when csel_0(i) = X"01" else
                phi(2) & theta(2) when csel_0(i) = X"02" else
                phi(3) & theta(3) when csel_0(i) = X"03" else
                (others => '0');
    end generate GEN_Q;
  
end BEHAV;
