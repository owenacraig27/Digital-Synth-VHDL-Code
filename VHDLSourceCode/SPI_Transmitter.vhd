-- library and packages
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity declaration
ENTITY MIDI_SPI IS
PORT (
    clk     : in  STD_LOGIC; -- system clock
  	Parallel_in : in STD_LOGIC_VECTOR(11 downto 0); -- 12 bit input signal
    New_Signal : in STD_LOGIC; -- signal to indicate new voltage is being sent
  	CS_Out  : out  STD_LOGIC;
  	Serial_out : out STD_LOGIC -- serially outputted signal
    
);
END MIDI_SPI;

-- Architecture
ARCHITECTURE behavioral OF MIDI_SPI IS

-- signal declarations
signal shift_reg : std_logic_vector(15 downto 0) := (others => '0');
signal counter : unsigned(3 downto 0) := (others => '0'); -- counter should count up to 15

signal CS : std_logic := '1'; -- chip select signal
signal count_en : std_logic := '0';
signal count_reset : std_logic := '0';
signal count_tc : std_logic := '0';
signal shift_en : std_logic := '0';
signal load_en : std_logic := '0';

CONSTANT MAXCOUNT : integer := 16;

-- State machine signal declarations
type state is (idle, load, shift, done);
signal currentstate, nextstate : state := idle;

BEGIN 
-- Datapath

-- shiftload process
shiftprocess : process(clk) begin
if rising_edge(clk) then
	if load_en = '1' then -- load in shift reg to be equal to load reg
    	shift_reg <= "0000" & Parallel_in;
    elsif shift_en = '1' then
    	shift_reg <= shift_reg(14 downto 0) & '0';
    end if;
end if;
end process shiftprocess; 

-- counter
counterprocess : process(clk) begin
if rising_edge(clk) then
	if count_reset = '1' then	
    	counter <= (others => '0');
    elsif count_en = '1' then
      	counter <= counter + 1;
   	end if;
end if;
end process counterprocess;

process (counter) begin 
	if (counter = MAXCOUNT-1) then 
    	count_tc <= '1';
    else 
    	count_tc <= '0';
  	end if;
end process;

-- asynchronous output
serial_out <= shift_reg(15);
CS_Out <= CS;

-- FSM 

-- state update logic
stateupdate : process(clk) 
begin
if rising_edge(clk) then
	currentstate <= nextstate;
end if;
end process stateupdate;

-- nextstate logic
nextstatelogic : process(currentstate, new_signal, count_tc) 
begin
nextstate <= currentstate; 
case currentstate is
	when idle =>
    	if new_signal = '1' then	
        	nextstate <= load;
        end if;
    when load =>
    	nextstate <= shift;
    when shift =>
    	if count_tc = '1' then	
        	nextstate <= done;
        end if;
    when done =>
    	nextstate <= idle;
    when others => nextstate <= idle;
end case; 
end process nextstatelogic;

-- output logic
output : process(currentstate) 
begin
	CS <= '1';
    load_en <= '0';
    shift_en <= '0';
    count_en <= '0';
    count_reset <= '0';
    
    case currentstate is 
    	when load =>
        	load_en <= '1';
    	when shift =>
        	CS <= '0';
            count_en <= '1';
            shift_en <= '1';
        when done =>
        	count_reset <= '1';
        when others => null;
    end case;
end process output;

END behavioral;