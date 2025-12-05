----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2025 09:59:21 PM
-- Design Name: 
-- Module Name: FINAL_SHELL - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FINAL_FINAL_SHELL is
  Port (clk_ext_port    : in std_logic;
        sci_in          : in std_logic ;
        spi_data         : out std_logic ;
        spi_clk         : out std_logic;
        spi_cs          : out std_logic;
        seg_ext_port    : out std_logic_vector(0 to 6);
        an_ext_port     : out std_logic_vector(3 downto 0) ;
        led             : out   std_logic);
end FINAL_FINAL_SHELL;

architecture Behavioral of FINAL_FINAL_SHELL is

component notecounter is
PORT (
    clk             : in std_logic;
    ch_sig		 	: in STD_LOGIC_VECTOR(7 downto 0); --  note on signal
    done            : in STD_LOGIC;
    numnotes        : out STD_LOGIC_VECTOR(1 downto 0)
);
end component;


component notememory IS
PORT (
    clk 	  		: in STD_LOGIC; 
    ch_sig		 	: in STD_LOGIC_VECTOR(7 downto 0); --  note on signal
    note_in  		: in  STD_LOGIC_VECTOR(7 downto 0);
    vel_in          : IN std_logic_vector(7 downto 0);
    sci_done 		: in STD_LOGIC;
	note1_out 		: out STD_LOGIC_VECTOR(7 downto 0);
    note2_out 		: out STD_LOGIC_VECTOR(7 downto 0);
    en1_out 		: out STD_LOGIC;
    en2_out 		: out STD_LOGIC;
    
    vel1_out        : out std_logic_vector(7 downto 0);
    vel2_out        : out std_logic_vector (7 downto 0)

);
end component;

component average IS
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
end component;


component Scaler IS
PORT ( 	
    clk 	  		: in STD_LOGIC; 
    New_signal_in 	: in STD_LOGIC; -- monopulsed in
    Velocity  		: in  STD_LOGIC_VECTOR(7 downto 0);
	Voltage_in  	: in  STD_LOGIC_VECTOR(11 downto 0);
    Voltage_out 	: out  STD_LOGIC_VECTOR(11 downto 0);
    New_signal_out 	: out  STD_LOGIC -- monopulsed out

);
end component;

component note2f is
  Port (note_ext    : in unsigned(7 downto 0);
        freq_ext    : out unsigned (9 downto 0) );
end component;

component SCI IS
PORT ( 	
    clk       : in  STD_LOGIC; 
	Data_in   : in  STD_LOGIC;
    Channel   : out STD_LOGIC_VECTOR(7 downto 0);
    note : out STD_LOGIC_VECTOR(7 downto 0);
    Velocity  : out STD_LOGIC_VECTOR(7 downto 0);
    SCI_done    : out std_logic 
);
end component;

component sinewave is
Port (clk   : in std_logic; 
      freq  :  in STD_LOGIC_VECTOR(9 downto 0);
      en    : in std_logic ;
      pval : out std_logic_vector (11 downto 0);
      new_pval : out std_logic);
end component;

component MIDI_SPI IS
PORT (
    clk     : in  STD_LOGIC; -- system clock
  	Parallel_in : in STD_LOGIC_VECTOR(11 downto 0); -- 12 bit input signal
    New_Signal : in STD_LOGIC; -- signal to indicate new voltage is being sent
  	CS_Out  : out  STD_LOGIC;
  	Serial_out : out STD_LOGIC -- serially outputted signal
    
);
END component;

component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;

component mux7seg is
    Port ( clk_port 	: in  std_logic;						--should get the 1 MHz system clk
         y3_port 		: in  std_logic_vector(3 downto 0);		--left most digit
         y2_port 		: in  std_logic_vector(3 downto 0);		--center left digit
         y1_port 		: in  std_logic_vector(3 downto 0);		--center right digit
         y0_port 		: in  std_logic_vector(3 downto 0);		--right most digit
         dp_set_port 	: in  std_logic_vector(3 downto 0);     --decimal points
         seg_port 	    : out  std_logic_vector(0 to 6);		--segments (a...g)
         dp_port 		: out  std_logic;						--decimal point
         an_port 		: out  std_logic_vector (3 downto 0) );	--anodes
         
end component;


-- SIGNAL DECLARATIONS  

signal sys_clk: std_logic := '0';

signal sample_spi   : std_logic := '0';
signal ch_sig   : std_logic_vector(7 downto 0) := (others => '0');
signal v_sig    : std_logic_vector(7 downto 0) := (others => '0');
signal spi_clk_sig: std_logic := '0';
signal note_sig : std_logic_vector(7 downto 0) := (others => '0');
signal clr_sig  : std_logic := '0';
signal done_sig  : std_logic := '0';
signal state_out_sig    : std_logic_vector(3 downto 0 ) := "0000";

signal note_1 : std_logic_vector(7 downto 0) := (others => '0');
signal note_2 : std_logic_vector(7 downto 0) := (others => '0');

signal en_sig_1  : std_logic := '0';
signal en_sig_2  : std_logic := '0';

signal vel_1 : std_logic_vector(7 downto 0) := (others => '0');
signal vel_2 : std_logic_vector(7 downto 0) := (others => '0');

signal freq_1    : std_logic_vector(9 downto 0) := (others => '0');
signal freq_2    : std_logic_vector(9 downto 0) := (others => '0');

signal unscaled_1   : std_logic_vector(11 downto 0) := (others => '0');
signal unscaled_2   : std_logic_vector(11 downto 0) := (others => '0');

signal sample_wave_1 : std_logic := '0';
signal sample_wave_2 : std_logic := '0';

signal note_cnt : std_logic_vector(1 downto 0) := "00";

signal sample_scaled_1 : std_logic := '0';
signal sample_scaled_2 : std_logic := '0';


signal parallel_scaled_1: std_logic_vector (11 downto 0) := (others => '0');
signal parallel_scaled_2: std_logic_vector (11 downto 0) := (others => '0');

signal final_voltage    :std_logic_vector (11 downto 0) := (others => '0');


begin

led <= ch_sig(4);


-- keeps track of how many notes are pressed at once
notecountblock : notecounter
PORT map (
    clk         => sys_clk,
    ch_sig		 => ch_sig, --  note on signal
    done         => done_sig,
    numnotes     => note_cnt
);


-- averages the voltages sent from each note
average_block: average 
port map(
	
    clk 	  		  => sys_clk,
    volt1_in 		  => parallel_scaled_1,
    volt2_in 		  => parallel_scaled_2,
    notenum           => note_cnt,
    new_signal1       => sample_scaled_1,
    new_signal2       => sample_scaled_2,
    volt_out		  => final_voltage,
    new_signal_out    => sample_spi
);


-- sends note, velocity, and channel signals from the SCI receiver 
--to appropriate wave gen and scaler blocks when multiple notes are pressed.
notememoryblock: notememory
port map (

    clk 	  		=> sys_clk,
    ch_sig		 	=> ch_sig,
    note_in  		=> note_sig,
    vel_in          => v_sig,
    sci_done 		=> done_sig,
	note1_out 		=> note_1,
    note2_out 		=> note_2,
    en1_out 		=> en_sig_1,
    en2_out 		=> en_sig_2,

    vel1_out        => vel_1,
    vel2_out        => vel_2
 


);

-- displays the frequency in hex, used for various hardware tests
seven_seg: mux7seg port map(
        clk_port	=> sys_clk,		--should get the 1 MHz system clk
        y3_port		=> "0000",		--left most digit
        y2_port 	=>"00" & freq_1 (9 downto 8),		--center left digit
        y1_port 	=> 	freq_1(7 downto 4),	--center right digit 
        y0_port 	=> 	freq_1(3 downto 0),	--right most digit
        dp_set_port => 	"0000",
        seg_port 	=> seg_ext_port,
        dp_port 	=> open,
        an_port 	=> an_ext_port);
        
        
-- scales down the generated wave according to the velocity value
linear_scaler1: Scaler 
PORT map ( 	
    clk 	  		=>  sys_clk ,
    New_signal_in 	=>  sample_wave_1,
    Velocity  		=>  vel_1  ,
	Voltage_in  	=>  unscaled_1,
    Voltage_out 	=>  parallel_scaled_1,
    New_signal_out 	=>  sample_scaled_1);

linear_scaler2: Scaler 
PORT map ( 	
    clk 	  		=>  sys_clk ,
    New_signal_in 	=>  sample_wave_2,
    Velocity  		=>  vel_2  ,
	Voltage_in  	=>  unscaled_2,
    Voltage_out 	=>  parallel_scaled_2,
    New_signal_out 	=>  sample_scaled_2
);


-- look up table converting note played to a frequency
 note_to_frequency1: note2f 
  Port map (note_ext => unsigned(note_1),
            std_logic_vector(freq_ext) => freq_1);

 note_to_frequency2: note2f 
  Port map (note_ext => unsigned(note_2),
            std_logic_vector(freq_ext) => freq_2);

-- divides 100MHz clock down to 10Hz and generates a forwarded clock for the SPI tx
clockdivider: system_clock_generator 
generic map( CLOCK_DIVIDER_RATIO => 10)
port map ( input_clk_port => clk_ext_port  ,
           system_clk_port => sys_clk,
           fwd_clk_port => spi_clk_sig );

-- wave gen: takes in a frequency and generates time-varying 12 bit sinusoidal signal
wave1 : sinewave
port map( clk =>sys_clk,
        freq => freq_1 , 
        en => en_sig_1,
        pval => unscaled_1, 
        new_pval => sample_wave_1);
        
wave2 : sinewave
port map( clk =>sys_clk,
        freq => freq_2 , 
        en => en_sig_2,
        pval => unscaled_2, 
        new_pval => sample_wave_2);
  
-- sends 12 bit spi signal to DA2 converter  
SPItx : midi_spi
port map (
    clk =>   sys_clk,   
  	Parallel_in => final_voltage,
    New_Signal => sample_spi ,
  	CS_Out  => spi_cs,
  	Serial_out => spi_data);
  
-- receives 3 bytes of SCI data and stores them in appropriate registers   
sci_rx:  SCI
    port map (
        clk       => sys_clk,
        Data_in   => sci_in,
        Channel   => ch_sig,
        note => note_sig,
        Velocity  => v_sig,
        SCI_done => done_sig );







--  TYING EVERYTHING TOGETHER  

spi_clk <= spi_clk_sig;
 

end Behavioral;
