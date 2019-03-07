library ieee;

use ieee.std_logic_1164.all;


package qbit_op is
  
  constant OP_FREERUN : std_logic_vector(7 downto 0) := X"01";
  constant OP_MEASURE : std_logic_vector(7 downto 0) := X"02";
    
  constant OP_CNOT : std_logic_vector(7 downto 0) := X"11";
  constant OP_X    : std_logic_vector(7 downto 0) := X"12";
  constant OP_Y    : std_logic_vector(7 downto 0) := X"13";
  constant OP_Z    : std_logic_vector(7 downto 0) := X"14";
  constant OP_H    : std_logic_vector(7 downto 0) := X"15";
  constant OP_CCX  : std_logic_vector(7 downto 0) := X"16";
  
  constant OP_U1 : std_logic_vector(7 downto 0) := X"21";  -- 1=U1
  constant OP_P  : std_logic_vector(7 downto 0) := X"22";  -- plus
  constant OP_T  : std_logic_vector(7 downto 0) := X"23";
  constant OP_S  : std_logic_vector(7 downto 0) := X"24";
  constant OP_U2 : std_logic_vector(7 downto 0) := X"25";  -- 2=U2
  constant OP_B  : std_logic_vector(7 downto 0) := X"26";
  constant OP_D  : std_logic_vector(7 downto 0) := X"27";  -- D=T†
  constant OP_E  : std_logic_vector(7 downto 0) := X"28";  -- E=S†
  constant OP_U3 : std_logic_vector(7 downto 0) := X"29";  -- 3=U3

end package qbit_op;
