-- averaging block
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity declaration
ENTITY average IS
PORT ( 	
    clk 	  		: in STD_LOGIC; 
    volt1_in 		: in  STD_LOGIC_VECTOR(11 downto 0);
    volt2_in 		: in  STD_LOGIC_VECTOR(11 downto 0);
    notenum         : in  STD_LOGIC_VECTOR(1 downto 0); -- number of notes on
    new_signal1   : in STD_LOGIC;
    new_signal2   : in STD_LOGIC;
    volt_out		: out  STD_LOGIC_VECTOR(11 downto 0);
    new_signal_out  : out  STD_LOGIC
);
end average;

-- architecture 
 ARCHITECTURE behavior of average is

signal volt1_reg        : std_logic_vector(11 downto 0) := (others => '0');
signal volt2_reg        : std_logic_vector(11 downto 0) := (others => '0');
signal sum_reg          : unsigned(11 downto 0) := (others => '0');
signal voltage_internal : std_logic_vector(11 downto 0) := (others => '0');

-- state machine signals
type state is (idle, load, sum, send);
signal currentstate, nextstate : state := idle; 

signal load_en     : std_logic := '0';
signal reset_load  : std_logic := '0';
signal sum_en      : std_logic := '0';
signal send_en     : std_logic := '0';
signal sum_reset   : std_logic := '0';

BEGIN 
-- datapath 

-- volt1 load average
loadv1 : process(clk) 
begin
if rising_edge(clk) then 
    if reset_load = '1' then 
        volt1_reg <= (others => '0');
    elsif load_en = '1' then
        if unsigned(notenum) = 2 then  
            volt1_reg <= '0' & volt1_in(11 downto 1);
        elsif unsigned(notenum) = 1 then   
            volt1_reg <= volt1_in;
        elsif unsigned(notenum) = 0 then   
            volt1_reg <= (others => '0');
        end if;
    end if;
end if;
end process loadv1;

-- volt2 load average
loadv2 : process(clk) 
begin
if rising_edge(clk) then 
    if reset_load = '1' then 
        volt2_reg <= (others => '0');
    elsif load_en = '1' then
        if unsigned(notenum) = 2 then  
            volt2_reg <= '0' & volt2_in(11 downto 1);
        elsif unsigned(notenum) = 1 then   
            volt2_reg <= volt2_in;
        elsif unsigned(notenum) = 0 then   
            volt2_reg <= (others => '0');
        end if;
    end if;
end if;
end process loadv2;

-- summing average
sumprocess : process(clk)
begin
if rising_edge(clk) then
    if sum_reset = '1' then  
        sum_reg <= (others => '0');
    elsif sum_en = '1' then
        sum_reg <= unsigned(volt1_reg) + unsigned(volt2_reg);
    end if;
end if;
end process sumprocess;

-- send process 
sendprocess : process(clk)
begin
if rising_edge(clk) then
    voltage_internal <= (others => '0');
    if send_en = '1' then
        voltage_internal <= std_logic_vector(sum_reg);
    end if;
end if;
end process sendprocess;

-- asynch output 
volt_out <= voltage_internal;

-- state machine logic

-- state update
stateupdate : process(clk) begin
if rising_edge(clk) then
	currentstate <= nextstate;
end if;
end process stateupdate;

-- next state logic
nextstatelogic : process(currentstate, new_signal1, new_signal2) 
begin
	nextstate <= currentstate;
    case currentstate is 
    	when idle =>
        	if new_signal1 = '1' or new_signal2 = '1' then
            	nextstate <= load;
            end if;
        when load =>
        	nextstate <= sum;
        when sum =>
        	nextstate <= send;
        when send =>
        	nextstate <= idle;
        when others => nextstate <= idle;
    end case;
end process nextstatelogic;

-- state output
stateoutput : process(currentstate) 
begin
	load_en <= '0';
    sum_en <= '0';
    sum_reset <= '0';
    new_signal_out <= '0';
    send_en <= '0';
    reset_load <= '0';
    
    case currentstate is 
    	when load =>
        	load_en <= '1';
        when sum =>
            sum_en <= '1';
            reset_load <= '1';
        when send =>
        	new_signal_out <= '1';
            send_en <= '1';
            sum_reset <= '1';
        when others => null;
    end case;
end process stateoutput;


end architecture behavior;

