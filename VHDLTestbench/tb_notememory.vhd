----------------------------------------------------------------------------------
-- Testbench for NoteMemory (Updated with velocity support)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_NoteMemory is
end entity;


architecture sim of tb_NoteMemory is

component NoteMemory is
    port  (
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
end component;

    -- DUT signals
    signal clk        : std_logic := '0';
    signal ch_sig     : std_logic_vector(7 downto 0) := (others => '0');
    signal note_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal vel_in     : std_logic_vector(7 downto 0) := (others => '0');
    signal sci_done   : std_logic := '0';

    signal note1_out  : std_logic_vector(7 downto 0);
    signal note2_out  : std_logic_vector(7 downto 0);
    signal vel1_out   : std_logic_vector(7 downto 0);
    signal vel2_out   : std_logic_vector(7 downto 0);
    signal en1_out    : std_logic;
    signal en2_out    : std_logic;

begin

    -- DUT instantiation
    DUT:  NoteMemory
    port map (
        clk        => clk,
        ch_sig     => ch_sig,
        note_in    => note_in,
        vel_in     => vel_in,
        sci_done   => sci_done,
        note1_out  => note1_out,
        note2_out  => note2_out,
        vel1_out   => vel1_out,
        vel2_out   => vel2_out,
        en1_out    => en1_out,
        en2_out    => en2_out
    );

    -- Clock generation: 100 MHz (10 ns period)
    clk <= not clk after 5 ns;

    -- Stimulus process
    stim_proc: process
    begin
        ---------------------------------------------------------
        -- First note ON (Note 60, Middle C, velocity = 100)
        ---------------------------------------------------------
        wait for 20 ns;
        note_in <= x"3C";              -- Note 60
        vel_in  <= x"64";              -- Velocity 100
        ch_sig  <= "10010000";         -- Note ON
        sci_done <= '1'; wait for 10 ns; sci_done <= '0';
        wait for 100 ns;

        ---------------------------------------------------------
        -- Second note ON (Note 64, E4, velocity = 80)
        ---------------------------------------------------------
        note_in <= x"40";              -- Note 64
        vel_in  <= x"50";              -- Velocity 80
        ch_sig  <= "10010000";         -- Note ON
        sci_done <= '1'; wait for 10 ns; sci_done <= '0';
        wait for 100 ns;

        ---------------------------------------------------------
        -- Second note OFF (Note 64)
        ---------------------------------------------------------
        note_in <= x"40";
        vel_in  <= x"00";              -- Velocity doesn't matter here
        ch_sig  <= "10000000";         -- Note OFF
        sci_done <= '1'; wait for 10 ns; sci_done <= '0';
        wait for 100 ns;

        ---------------------------------------------------------
        -- First note OFF (Note 60)
        ---------------------------------------------------------
        note_in <= x"3C";
        vel_in  <= x"00";
        ch_sig  <= "10000000";         -- Note OFF
        sci_done <= '1'; wait for 10 ns; sci_done <= '0';
        wait for 100 ns;

        ---------------------------------------------------------
        -- End simulation
        ---------------------------------------------------------
        wait;
    end process;

end architecture;
