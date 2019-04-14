-- -*- coding: utf-8 -*-
library ieee;

use ieee.std_logic_1164.all;


package qbit_op is
  
  constant OP_CLR     : std_logic_vector(7 downto 0) := X"FF";
  constant OP_FREERUN : std_logic_vector(7 downto 0) := X"FE";
  constant OP_MEASURE : std_logic_vector(7 downto 0) := X"FD";
    
  constant OP_X  : std_logic_vector(7 downto 0) := X"10";
  constant OP_Y  : std_logic_vector(7 downto 0) := X"11";
  constant OP_Z  : std_logic_vector(7 downto 0) := X"12";
  constant OP_H  : std_logic_vector(7 downto 0) := X"13";
  constant OP_S  : std_logic_vector(7 downto 0) := X"14";
  constant OP_SD : std_logic_vector(7 downto 0) := X"15";  -- S†
  constant OP_T  : std_logic_vector(7 downto 0) := X"16";
  constant OP_TD : std_logic_vector(7 downto 0) := X"17";  --T†
  
  constant OP_CNOT : std_logic_vector(7 downto 0) := X"20";
  constant OP_CCX  : std_logic_vector(7 downto 0) := X"21";

end package qbit_op;
