library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bloch_point_gen is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    seed      : in std_logic_vector(31 downto 0);
    init_seed : in std_logic;

    theta : out std_logic_vector(31 downto 0);
    phi   : out std_logic_vector(31 downto 0);
    valid : out std_logic
    );
end bloch_point_gen;

architecture RTL of bloch_point_gen is

  component xorshift32
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      seed  : in  std_logic_vector(31 downto 0);
      init  : in  std_logic;
      q     : out std_logic_vector(31 downto 0)
      );
  end component xorshift32;

  component conv_uint32_to_float
    port (
      aclk                 : in  std_logic;
      s_axis_a_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_a_tvalid      : in  std_logic;
      m_axis_result_tdata  : out std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic
      );
  end component conv_uint32_to_float;

  component conv_float_to_int32
    port (
      aclk                 : in  std_logic;
      s_axis_a_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_a_tvalid      : in  std_logic;
      m_axis_result_tdata  : out std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic
      );
  end component conv_float_to_int32;
  
  component fadd_single
    port (
      aclk                 : in  std_logic;
      s_axis_a_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_a_tvalid      : in  std_logic;
      s_axis_b_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_b_tvalid      : in  std_logic;
      m_axis_result_tdata  : out std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic
      );
  end component fadd_single;

  component fdiv_single
    port (
      aclk                 : in  std_logic;
      s_axis_a_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_a_tvalid      : in  std_logic;
      s_axis_b_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_b_tvalid      : in  std_logic;
      m_axis_result_tdata  : out std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic
      );
  end component fdiv_single;

  component fmul_single
    port (
      aclk                 : in  std_logic;
      s_axis_a_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_a_tvalid      : in  std_logic;
      s_axis_b_tdata       : in  std_logic_vector(31 downto 0);
      s_axis_b_tvalid      : in  std_logic;
      m_axis_result_tdata  : out std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic
      );
  end component fmul_single;

  signal q       : std_logic_vector(31 downto 0) := (others => '0');
  signal q_valid : std_logic;
  
  signal convf_value  : std_logic_vector(31 downto 0) := (others => '0');
  signal convf_valid  : std_logic                     := '0';
  signal fadd_value  : std_logic_vector(31 downto 0) := (others => '0');
  signal fadd_valid  : std_logic                     := '0';
  signal fdiv_value  : std_logic_vector(31 downto 0) := (others => '0');
  signal fdiv_valid  : std_logic                     := '0';
  signal fmul_value  : std_logic_vector(31 downto 0) := (others => '0');
  signal fmul_valid  : std_logic                     := '0';
  signal convi_value : std_logic_vector(31 downto 0) := (others => '0');
  signal convi_valid : std_logic                     := '0';

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
  U_CONVF : conv_uint32_to_float
    port map(
      aclk                 => clk,
      s_axis_a_tdata       => q,
      s_axis_a_tvalid      => q_valid,
      m_axis_result_tdata  => convf_value,
      m_axis_result_tvalid => convf_valid
      );

  U_FADD : fadd_single
    port map(
      aclk                 => clk,
      s_axis_a_tdata       => convf_value,
      s_axis_a_tvalid      => convf_valid,
      s_axis_b_tdata       => X"3F800000",  -- 1.0
      s_axis_b_tvalid      => convf_valid,
      m_axis_result_tdata  => fadd_value,
      m_axis_result_tvalid => fadd_valid
      );

  U_FDIV : fdiv_single
    port map(
      aclk                 => clk,
      s_axis_a_tdata       => fadd_value,
      s_axis_a_tvalid      => fadd_valid,
      s_axis_b_tdata       => X"4F800000", -- 4294967296.0(2^32)
      s_axis_b_tvalid      => fadd_valid,
      m_axis_result_tdata  => fdiv_value,
      m_axis_result_tvalid => fdiv_valid
      );

  U_FMUL : fmul_single
    port map(
      aclk                 => clk,
      s_axis_a_tdata       => fdiv_value,
      s_axis_a_tvalid      => fdiv_valid,
      s_axis_b_tdata       => X"43b40000", -- 360.0
      s_axis_b_tvalid      => fdiv_valid,
      m_axis_result_tdata  => fmul_value,
      m_axis_result_tvalid => fmul_valid
      );

  U_CONVI : conv_float_to_int32
    port map(
      aclk                 => clk,
      s_axis_a_tdata       => fmul_value,
      s_axis_a_tvalid      => fmul_valid,
      m_axis_result_tdata  => convi_value,
      m_axis_result_tvalid => convi_valid
      );

  process(clk)
  begin
    if rising_edge(clk) then
      if convi_valid = '1' then
        flag <= not flag;
        if flag = '0' then
          theta <= std_logic_vector(shift_right(signed(convi_value), 1)); -- 0 < theta < 180
        else
          phi   <= convi_value;
        end if;
      end if;
      valid <= convi_valid and flag;
    end if;
  end process;

end RTL;
