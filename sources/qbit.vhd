library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.qbit_op.all;

entity qbit is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    seed      : in std_logic_vector(31 downto 0);
    init_seed : in std_logic;

    operator    : in std_logic_vector(7 downto 0);
    operator_en : in std_logic;

    info_cnot_out   : out std_logic_vector(7 downto 0);
    info_cnot_valid : out std_logic;
    info_cnot_en    : in  std_logic;
    info_cnot_in    : in  std_logic_vector(7 downto 0);

    phi   : out std_logic_vector(31 downto 0);
    theta : out std_logic_vector(31 downto 0)
    );
end qbit;

architecture RTL of qbit is
  
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
  
  signal phi_i   : std_logic_vector(31 downto 0);
  signal theta_i : std_logic_vector(31 downto 0);
  signal valid   : std_logic;
  
  signal phi_reg   : signed(31 downto 0);
  signal theta_reg : signed(31 downto 0);

  signal op_reg   : std_logic_vector(7 downto 0);

begin

  phi   <= std_logic_vector(phi_reg);
  theta <= std_logic_vector(theta_reg);

  U_BLOCH: bloch_point_gen
    port map(
      clk   => clk,
      reset => reset,

      seed      => seed,
      init_seed => init_seed,

      theta => theta_i,
      phi   => phi_i,
      valid => valid
      );

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        theta_reg       <= to_signed(0, theta_reg'length);
        phi_reg         <= to_signed(0, phi_reg'length);
        info_cnot_valid <= '0';
      elsif info_cnot_en = '1' then
        if info_cnot_in = X"01" then
          -- X
          theta_reg <= 180 - theta_reg; 
          phi_reg <= 360 - shift_left(phi_reg, 1);
        elsif info_cnot_in = X"03" then
          -- entanglement
          theta_reg <= 90;
          phi_reg <= 0;
        end if;
      elsif operator_en = '0' and op_reg = OP_FREERUN and valid = '1' then
        theta_reg       <= signed(theta_i);
        phi_reg         <= signed(phi_i);
        info_cnot_valid <= '0';
      elsif operator_en = '1' then
        op_reg          <= operator;
        info_cnot_valid <= '0';
        
        case operator is
          when OP_FREERUN =>
            if valid = '1' then
              theta_reg <= signed(theta_i);
              phi_reg   <= signed(phi_i);
            end if;
          when OP_MEASURE =>
            null;
          when OP_CNOT =>
            if theta_reg = 90 and phi_reg = 0 then
              info_cnot <= X"03";
            elsif theta_reg = 180 then
              info_cnot_out <= X"01";
            else
              info_cnot_out <= X"00";
            end if;
            info_cnot_valid <= '1';
          when OP_X =>
            theta_reg <= 180 - theta_reg;
            phi_reg   <= 360 - shift_left(phi_reg, 1);
          when OP_Y =>
            theta_reg  <= 180 - theta_reg;
            if phi_reg <= 180 then
              phi_reg <= 180 - phi_reg;
            elsif phi_reg > 180 then
              phi_reg <= 360 - phi_reg;
            end if;
          when OP_Z =>
            if phi_reg <= 180 then
              phi_reg <= 180 + phi_reg;
            elsif phi_reg > 180 then
              phi_reg <= phi_reg - 180;
            end if;
          when OP_CCX =>
            null;
          when OP_H =>
            if ((phi_reg <= 45) or (phi_reg >= 315)) then
              if (theta_reg <= 45) then
                phi_reg   <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 135) then
                phi_reg   <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(0, theta_reg'length);
              elsif (theta_reg <= 180) then
                phi_reg   <= to_signed(180, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif ((phi_reg > 45) and (phi_reg <= 135)) then
                if (theta_reg <= 45) then
                  phi_reg   <= to_signed(0, phi_reg'length);
                  theta_reg <= to_signed(90, theta_reg'length);
                elsif (theta_reg <= 135) then
                  phi_reg   <= to_signed(270, phi_reg'length);
                  theta_reg <= to_signed(90, theta'length);
                elsif (theta_reg <= 180) then
                  phi_reg   <= to_signed(180, phi_reg'length);
                  theta_reg <= to_signed(90, theta_reg'length);
                end if;
              end if;
            elsif ((phi_reg > 135) and (phi_reg <= 225)) then
              if (theta_reg <= 45) then
                phi_reg   <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 135) then
                phi_reg   <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(180, theta_reg'length);
              elsif (theta_reg <= 180) then
                phi_reg   <= to_signed(180, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              end if;
            elsif ((phi_reg > 225) and phi_reg < 315) then
              if (theta_reg <= 45) then
                phi_reg   <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 135) then
                phi_reg   <= to_signed(90, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 180) then
                phi_reg   <= to_signed(180, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              end if;
            end if;
          when OP_U1 =>
            null;
          when OP_P =>
            null;
          when OP_T =>
            if (phi_reg >= 315) then
              phi_reg <= phi_reg + 45 - 360;
            else
              phi_reg <= phi_reg + 45;
            end if;
          when OP_S =>
            if (phi_reg >= 315) then
              phi_reg <= phi_reg + 45 -360;
            else
              phi_reg <= phi_reg + 45;
            end if;
          when OP_U2 =>
            null;
          when OP_B =>
            null;
          when OP_D =>
            if (phi_reg <= 45) then
              phi_reg <= phi_reg - 45 + 360;
            else
              phi_reg <= phi_reg - 45;
            end if;
          when OP_E =>
            if (phi_reg <= 90) then
              phi_reg <= phi_reg - 90 + 360;
            else
              phi_reg <= phi_reg - 90;
            end if;
          when OP_U3 =>
            null;
          when others =>
            null;
        end case;
      end if;
    end if;
  end process;
  
end RTL;
