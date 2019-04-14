-- -*- coding: utf-8 -*-
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

    operator    : in std_logic_vector(23 downto 0);
    operator_en : in std_logic;

    csel_0 : out std_logic_vector(7 downto 0);
    cin_0  : in  std_logic_vector(63 downto 0);
    csel_1 : out std_logic_vector(7 downto 0);
    cin_1  : in  std_logic_vector(63 downto 0);

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

  csel_0 <= operator(15 downto 8);
  csel_1 <= operator(23 downto 16);

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        theta_reg       <= to_signed(0, theta_reg'length);
        phi_reg         <= to_signed(0, phi_reg'length);
      elsif operator_en = '0' then
        if op_reg = OP_FREERUN and valid = '1' then
          theta_reg <= signed(theta_i);
          phi_reg   <= signed(phi_i);
        end if;
      else -- operator_en = '1'
        op_reg <= operator(7 downto 0);
        case(operator(7 downto 0)) is
          when OP_CLR =>
            theta_reg <= to_signed(0, theta_reg'length);
            phi_reg   <= to_signed(0, phi_reg'length);
          when OP_FREERUN =>
            if valid = '1' then
              theta_reg <= signed(theta_i);
              phi_reg   <= signed(phi_i);
            end if;
          when OP_MEASURE =>
            null;
          when OP_X =>
            theta_reg <= 180 - theta_reg;
            -- phi_reg   <= 360 - 2 * phi_reg;
            phi_reg   <= 360 - (phi_reg(30 downto 0) & '0');
          when OP_Y =>
            theta_reg <= 180 - theta_reg;
            phi_reg   <= 180 - phi_reg;
          when OP_Z =>
            theta_reg <= theta_reg;
            phi_reg   <= 180 + phi_reg;
          when OP_S =>
            theta_reg <= theta_reg;
            phi_reg   <= phi_reg + 90;
          when OP_SD =>
            theta_reg <= theta_reg;
            phi_reg   <= phi_reg - 90;
          when OP_T =>
            theta_reg <= theta_reg;
            phi_reg   <= phi_reg + 45;
          when OP_TD =>
            theta_reg <= theta_reg;
            phi_reg   <= phi_reg - 45;
          when OP_H =>
            if((phi_reg <= 45) or (phi_reg >= 315)) then
              if (theta_reg <= 45) then
                phi_reg <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(90, theta'length);
              elsif (theta_reg <= 135) then
                phi_reg <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(0, theta_reg'length);
              elsif (theta_reg <= 180) then
                phi_reg <= to_signed(180, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              end if;
            elsif ((phi_reg > 45) and (phi_reg <= 135)) then
              if (theta_reg <= 45) then
                phi_reg <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 135) then
                phi_reg <= to_signed(270, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 180) then
                phi_reg <= to_signed(180, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              end if;
            elsif ((phi_reg > 135) and (phi_reg <= 225)) then
              if (theta_reg <=45) then
                phi_reg <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 135) then
                phi_reg <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(180, theta_reg'length);
              elsif (theta_reg <= 180) then
                phi_reg <= to_signed(180, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              end if;
            elsif ((phi_reg > 225) and phi_reg <315) then
              if (theta_reg <= 45) then
                phi_reg <= to_signed(0, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 135) then
                phi_reg <= to_signed(90, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              elsif (theta_reg <= 180) then
                phi_reg <= to_signed(180, phi_reg'length);
                theta_reg <= to_signed(90, theta_reg'length);
              end if;
            end if;
          when OP_CNOT =>
            if signed(cin_0(31 downto 0)) = 0 then
              theta_reg <= theta_reg;
            elsif signed(cin_0(31 downto 0)) = 180 then
              theta_reg <= 180 - theta_reg;
            else
              theta_reg <= to_signed(90, theta_reg'length);
              phi_reg <= to_signed(0, phi_reg'length);
            end if;
            
          when OP_CCX =>
            if signed(cin_0(31 downto 0)) = 180 and signed(cin_1(31 downto 0)) = 180 then
              theta_reg <= 180 - theta_reg;
            else
              theta_reg <= to_signed(90, theta_reg'length);
              phi_reg <= to_signed(0, phi_reg'length);
            end if;
            
          when others =>
            null;
            
        end case;
        
      end if;
    end if;
  end process;
  
end RTL;
