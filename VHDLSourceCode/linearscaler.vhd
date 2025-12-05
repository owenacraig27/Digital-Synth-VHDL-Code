--18 bit Scaling Block Datapath and state machine

--library and package imports 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity declaration
ENTITY Scaler IS
PORT ( 	
    clk 	  		: in STD_LOGIC; 
    New_signal_in 	: in STD_LOGIC; -- monopulsed in
    Velocity  		: in  STD_LOGIC_VECTOR(7 downto 0);
	Voltage_in  	: in  STD_LOGIC_VECTOR(11 downto 0);
    Voltage_out 	: out  STD_LOGIC_VECTOR(11 downto 0);
    New_signal_out 	: out  STD_LOGIC -- monopulsed out
);
end Scaler;

-- architecture 
ARCHITECTURE behavior of Scaler is



-- signal declaration
signal sum_reg 		: unsigned(18 downto 0) := (others => '0'); -- max 19 bits required
signal load_reg 	: std_logic_vector(11 downto 0) := (others => '0');
signal scaled_reg 	: std_logic_vector(11 downto 0) := (others => '0');
signal counter		: unsigned(6 downto 0) := (others => '0'); -- max velocity is 7 bits (127)


signal velocity_reg 		: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal voltage_out_internal :STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

-- state machine signals
type state is (idle, load, sum, send);
signal currentstate, nextstate : state := idle; 

signal count_en 	: std_logic := '0';
signal count_reset  : std_logic := '0';
signal count_tc 	: std_logic := '0';

signal velocity_en 	: std_logic := '0';
signal load_en 		: std_logic := '0';
signal send_en 		: std_logic := '0';
signal sum_en	 	: std_logic := '0';
signal sum_reset 	: std_logic := '0';


BEGIN

-- Datapath

-- velocity reg
-- assigns input velocity to be saved ina register
loadvelocity : process(clk) begin
if rising_edge(clk) then
	if velocity_en = '1' then
    	velocity_reg <= Velocity;
    end if;
end if;
end process loadvelocity;

-- load register
loadprocess : process(clk) begin
if rising_edge(clk) then
	if load_en = '1' then
    	load_reg <= voltage_in;
    end if;
end if;
end process loadprocess;

-- counter
countprocess : process(clk) 
begin
	if rising_edge(clk) then
    	if count_reset = '1' then
        	counter <= (others => '0');
        elsif count_en = '1' then
        	counter <= counter + 1;
        end if;
    end if;
end process countprocess;

-- TC signal assignment
process(counter, velocity_reg) 
begin
	if counter = unsigned(velocity_reg) - 1 then
    	count_tc <= '1';
    else
    	count_tc <= '0';
    end if;
end process; 

-- sumprocess
sumprocess : process(clk)
begin
if rising_edge(clk) then
	if sum_reset = '1' then
    	sum_reg <= (others => '0');
    elsif sum_en = '1' then
    	sum_reg <= sum_reg + unsigned(load_reg);
    end if;
end if;
end process sumprocess; 


-- concatenation process
scaled_reg <= '0' & std_logic_vector(sum_reg(18 downto 8));

-- sending process
sendprocess : process(clk) 
begin
if rising_edge(clk) then
	if send_en = '1' then
    	voltage_out_internal <= scaled_reg;
    end if;
end if;
end process sendprocess;

-- Asynch output
voltage_out <= voltage_out_internal;

-- state machine logic

-- state update
stateupdate : process(clk) begin
if rising_edge(clk) then
	currentstate <= nextstate;
end if;
end process stateupdate;

-- next state logic
nextstatelogic : process(currentstate, new_signal_in, count_tc) 
begin
	nextstate <= currentstate;
    case currentstate is 
    	when idle =>
        	if new_signal_in = '1' then
            	nextstate <= load;
            end if;
        when load =>
        	nextstate <= sum;
        when sum => 
        	if count_tc = '1' then
            	nextstate <= send;
            elsif new_signal_in = '1' then
                nextstate <= load;
            end if;
        when send =>
        	nextstate <= idle;
        when others => nextstate <= idle;
    end case;
end process nextstatelogic;


-- state output
stateoutput : process(currentstate) 
begin
	load_en <= '0';
    count_en <= '0';
    count_reset <= '0';
    sum_en <= '0';
    sum_reset <= '0';
    new_signal_out <= '0';
    send_en <= '0';
    velocity_en <= '0';
    
    
    case currentstate is 
    	when load =>
        	load_en <= '1';
            velocity_en <= '1';
        when sum =>
        	count_en <= '1';
            sum_en <= '1';
        when send =>
        	new_signal_out <= '1';
            send_en <= '1';
            count_reset <= '1';
            sum_reset <= '1';
        when others => null;
    end case;
end process stateoutput;






end architecture behavior;
