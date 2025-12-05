--SCI Transmitter Datapath and state machine

--library and package imports 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity declaration
ENTITY SCI IS
PORT ( 	
    clk       : in  STD_LOGIC; 
	Data_in   : in  STD_LOGIC;
    Channel   : out STD_LOGIC_VECTOR(7 downto 0);
    note : out STD_LOGIC_VECTOR(7 downto 0);
    Velocity  : out STD_LOGIC_VECTOR(7 downto 0);
    SCI_done    : out STD_LOGIC 
);
end SCI;

-- architecture 
ARCHITECTURE behavior of SCI is

-- signal declaration
signal baud_cnt   : unsigned(8 downto 0) := (others => '0');
signal half_baud_cnt  : unsigned(7 downto 0) := (others => '0');
signal byte_cnt: unsigned(1 downto 0) := "00";
signal bit_cnt: unsigned (3 downto 0) :="0000";
signal shift_reg: std_logic_vector( 9 downto 0) := (others => '0');

-- output registers
signal channel_reg   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal note_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal velocity_reg  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');


-- state machine declarations
type state is (idle, half_baud_wait, baud_wait, shift, load_channel, wait1, load_note, wait2, load_velocity, done);
signal current_state, next_state : state := idle; 

signal half_baud_clr : std_logic := '0';
signal baud_clr : std_logic := '0';
signal half_baud_tc  : std_logic := '0';
signal baud_tc  : std_logic := '0';
signal bit_en   : std_logic := '0';
signal bit_tc   : std_logic := '0';
signal byte_en  : std_logic := '0';
signal byte_tc  : std_logic := '0';
signal bit_clr : std_logic := '0';
signal byte_clr: std_logic := '0';
signal shift_en: std_logic := '0';
signal note_en: std_logic := '0';
signal velocity_en: std_logic := '0';
signal channel_en: std_logic := '0';
signal sync1    : std_logic := '1';
signal data_sync    : std_logic := '1';

CONSTANT BAUD_PERIOD : integer := 320; -- number of clock cycles for one baud period
CONSTANT HALF_PERIOD : integer := 160;
CONSTANT BIT_NUMBER  : integer := 10;    -- 9 bits until reset
CONSTANT BYTE_NUMBER : integer := 3;    -- 3 bytes total


BEGIN

-- double flip flop synchronizer process 
process (clk)begin
    if (rising_edge(clk)) then
        sync1 <= data_in;
    end if;
end process;

process (clk)begin
    if (rising_edge(clk)) then
        data_sync <= sync1;
    end if;
end process;
-- datapath
-- start counter (counts half of baud count)
half_baud_counter : process(clk) 
begin
if rising_edge(clk) then
    if half_baud_clr = '1' or half_baud_tc = '1' then
        half_baud_cnt <= (others => '0');
    else 
        half_baud_cnt <= half_baud_cnt + 1;
    end if;
end if;
end process;
-- half baud TC process
process (half_baud_cnt) begin 
	if (half_baud_cnt = HALF_PERIOD -1) then 
    	half_baud_tc <= '1';
    else 
    	half_baud_tc <= '0';
  	end if;
end process;


-- baudcounter (full baud count)
baudcounter : process(clk) 
begin
if rising_edge(clk) then
    if baud_tc ='1' or baud_clr = '1' then 
        baud_cnt <= (others => '0');
    else
        baud_cnt <= baud_cnt + 1;
    end if;
end if;
end process baudcounter;
-- asynchronous baud_tc
process (baud_cnt) begin 
	if (baud_cnt = BAUD_PERIOD -1) then 
    	baud_tc <= '1';
    else 
    	baud_tc <= '0';
  	end if;
end process;




-- bitcounter
bitcounter : process(clk) 
begin
if rising_edge(clk) then
    if bit_clr = '1' then 
        bit_cnt <= (others => '0');
    elsif bit_en = '1' then 
        if bit_tc = '1' then   
            bit_cnt <= (others => '0');
        else 
            bit_cnt <= bit_cnt + 1;
        end if;
    end if;
end if;
end process bitcounter;

-- bit count TC
process (bit_cnt) begin 
	if (bit_cnt = BIT_NUMBER -1) then 
    	bit_tc <= '1';
    else 
    	bit_tc <= '0';
  	end if;
end process;


-- bytecounter
bytecounter : process(clk) 
begin
if rising_edge(clk) then
    if( byte_clr = '1') then
        byte_cnt <= (others => '0');
    elsif (byte_en = '1') then
        if byte_tc = '1' then	
            byte_cnt <= (others => '0');
        else
            byte_cnt <= byte_cnt + 1;
        end if;
    end if;
end if;
end process bytecounter;
-- byte count TC
process (byte_cnt) begin 
	if (byte_cnt = BYTE_NUMBER -1) then 
    	byte_tc <= '1';
    else 
    	byte_tc <= '0';
  	end if;
end process;


-- shift register
shift_proc: process(clk) 
begin
	if rising_edge(clk) then
    	if shift_en= '1' then
        	shift_reg <= data_sync & shift_reg(9 downto 1);
        end if;
    end if;
end process shift_proc;

-- output registers

-- channel register 
process(clk) 
begin
if rising_edge(clk) then
	if ( channel_en = '1') then   
	   channel_reg <= shift_reg(9 downto 2);
	end if;
end if;
end process;

-- note register
process(clk) 
begin
if rising_edge(clk) then
	if ( note_en = '1') then   
	   note_reg <= shift_reg(9 downto 2);
	end if;
end if;
end process;

-- velocity register
process(clk) 
begin
if rising_edge(clk) then
	if ( velocity_en = '1') then   
	   velocity_reg <= shift_reg(9 downto 2);
	end if;
end if;
end process;

-- asynchronous outputs
Channel   <= channel_reg;
note <= note_reg;
Velocity  <= velocity_reg;


--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- state machine processes

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- state update logic
stateupdate : process(clk) 
begin
if rising_edge(clk) then
	current_state <= next_state;
end if;
end process stateupdate;

-- nextstate logic
nextstatelogic : process(current_state, data_sync, byte_cnt, baud_tc, half_baud_tc, bit_tc) 
begin
next_state <= current_state; 
case current_state is
	when idle =>
    	if data_sync = '0' then
        	next_state <= half_baud_wait;
        end if;
    when half_baud_wait =>
    	if half_baud_tc = '1' then
        	next_state <= shift;
        end if;
    when shift =>
        next_state <= baud_wait;
    when baud_wait =>
        if(baud_tc = '1' and bit_tc = '1' and byte_cnt = "00") then 
            next_state <= load_channel;
        elsif(baud_tc = '1' and bit_tc = '1' and byte_cnt = "01") then 
            next_state <= load_note;
        elsif(baud_tc = '1' and bit_tc = '1' and byte_cnt = "10") then 
            next_state <= load_velocity;
        elsif (baud_tc = '1') then 
            next_state <= shift;
        end if;
    when load_channel => 
        next_state <= wait1;
    when wait1 =>
        if( data_sync = '0') then 
            next_state <= half_baud_wait ;
        end if;
    when load_note =>
        next_state <= wait2;
    when wait2 => 
        if (data_sync = '0') then
            next_state <= half_baud_wait;
        end if; 
    when load_velocity => 
        next_state <= done;
    when done => 
        next_state <= idle;
     
end case; 
end process nextstatelogic;

-- output logic
output : process(current_state) 
begin
    -- defaults 
    bit_en <= '0';
    byte_en <= '0';
    channel_en <= '0';
    velocity_en <= '0';
    note_en <= '0';
    shift_en <= '0';
    half_baud_clr <= '0';
    baud_clr <= '0';
    bit_clr <= '0';
    byte_clr <= '0';
    sci_done <= '0';
    
    
    
    
    case current_state is 
    	when idle =>
    	   	half_baud_clr <= '1';
            baud_clr <= '1';
            bit_clr <= '1';
            byte_clr <= '1';
    	when half_baud_wait =>
        	baud_clr <= '1';
        when shift => 
            bit_en <= '1';
            shift_en <= '1';
        when baud_wait => null;
        when load_channel => 
            channel_en <= '1';
            byte_en <= '1';
        when wait1 => 
            half_baud_clr <= '1';
            baud_clr <= '1';
            bit_clr <= '1';
        when load_note => 
            note_en <= '1';
            byte_en <= '1';
        when wait2 => 
            half_baud_clr <= '1';
            baud_clr <= '1';
            bit_clr <= '1';
        when load_velocity =>
            velocity_en <= '1'; 
        when done => 
            sci_done <= '1';      
    end case;
end process output;

end architecture behavior;
