
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity notecounter is
PORT (
    clk             : in STD_LOGIC;
    ch_sig		 	: in STD_LOGIC_VECTOR(7 downto 0); --  note on signal
    done            : in STD_LOGIC;
    numnotes        : out STD_LOGIC_VECTOR(1 downto 0)
);
end notecounter;

architecture Behavioral of notecounter is
signal numnotes_internal :  unsigned(1 downto 0) := "00"; -- initialize counter to 0

-- adding or subtracting from the register depending on the signals
begin
process (clk) begin
if (rising_edge(clk)) then
    if done = '1' then
        if ch_sig(4) = '1' then
            numnotes_internal <= numnotes_internal + 1;
        else
            numnotes_internal <= numnotes_internal - 1;
        end if;
    end if;
end if;
end process;

-- asynchronously assign output
numnotes <= std_logic_vector(numnotes_internal);
  


end  Behavioral;
