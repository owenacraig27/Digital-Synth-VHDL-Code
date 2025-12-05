-- Note Memory Block

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity declaration
ENTITY NoteMemory IS
PORT ( 	
    clk 	  		: in STD_LOGIC; 
    ch_sig		 	: in STD_LOGIC_VECTOR(7 downto 0); --  note on signal
    note_in  		: in  STD_LOGIC_VECTOR(7 downto 0);
    vel_in          : IN std_logic_vector(7 downto 0);
    sci_done 		: in STD_LOGIC;
	note1_out 		: out STD_LOGIC_VECTOR(7 downto 0);
    note2_out 		: out STD_LOGIC_VECTOR(7 downto 0);
    
    vel1_out        : out std_logic_vector(7 downto 0);
    vel2_out        : out std_logic_vector (7 downto 0);
    
    en1_out 		: out STD_LOGIC;
    en2_out 		: out STD_LOGIC

);
end NoteMemory;

-- architecture 
ARCHITECTURE behavior of NoteMemory is

-- signals
signal note_internal: std_logic_vector(7 downto 0) := (others => '0');
signal note1_reg 	: std_logic_vector(7 downto 0) := (others => '0');
signal note2_reg 	: std_logic_vector(7 downto 0) := (others => '0');
signal note_on 		: std_logic := '0'; -- saves ch_sig signal

-- state machine signals
type state is (idle, load, done);
signal currentstate, nextstate : state := idle; 
signal load_note : std_logic := '0';
signal reset_note : std_logic := '0';
signal vel_internal : std_logic_vector(7 downto 0) := (others => '0');
signal vel1_reg     : std_logic_vector(7 downto 0) := (others => '0');
signal vel2_reg     : std_logic_vector (7 downto 0) := (others => '0');


BEGIN

-- saving note_in and note_on
process(clk)
begin
if rising_edge(clk) then
	if reset_note = '1' then
    	note_internal <= (others => '0');
        note_on <= '0';
    elsif load_note = '1' then
    	note_internal <= note_in;
        note_on <= ch_sig(4);
        vel_internal <= vel_in;
    end if;
end if;
end process;

-- storing and clearingprocess
storeprocess : process(clk) 
begin
if rising_edge(clk) then
	if note_on = '1' and unsigned(note1_reg) = 0 then
    	note1_reg <= note_internal;
    	vel1_reg <= vel_internal;
    elsif note_on = '1' and unsigned(note2_reg) = 0 then
    	note2_reg <= note_internal;
    	vel2_reg <= vel_internal;
    elsif note_on = '0' and note1_reg = note_internal then
    	note1_reg <= (others => '0');
    	vel1_reg <= (others => '0');
    elsif note_on = '0' and note2_reg = note_internal then
    	note2_reg <= (others => '0');
    	vel2_reg <= (others => '0');
    end if;
end if;
end process storeprocess; 

-- asynch output
note1_out <= note1_reg;
note2_out <= note2_reg;

vel1_out <= vel1_reg;
vel2_out <= vel2_reg;

-- enable process;
process(note1_reg) 
begin
en1_out <= '0';
if unsigned(note1_reg) /= 0 then
	en1_out <= '1';
end if;
end process;

process(note2_reg) 
begin
en2_out <= '0';
if unsigned(note2_reg) /= 0 then
	en2_out <= '1';
end if;
end process;


-- state machine shit

-- state update
stateupdate : process(clk) begin
if rising_edge(clk) then
	currentstate <= nextstate;
end if;
end process stateupdate;

-- next state logic
nextstatelogic : process(currentstate, sci_done) 
begin
	nextstate <= currentstate;
    case currentstate is 
    	when idle =>
        	if sci_done = '1' then
            	nextstate <= load;
            end if;
        when load =>
        	nextstate <= done;
        when done =>
            nextstate <= idle;
        when others => nextstate <= idle;
    end case;
end process nextstatelogic;

-- state output
stateoutput : process(currentstate) 
begin
    load_note <= '0';
    reset_note <= '0';
    case currentstate is 
    	when load =>
			load_note <= '1';
        when done =>
            reset_note <= '1';
        when others => null;
    end case;
end process stateoutput;



end architecture behavior;
