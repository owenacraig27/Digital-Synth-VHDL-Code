library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_SCI is
end tb_SCI;

architecture sim of tb_SCI is

component sci IS
PORT ( 	
    clk       : in  STD_LOGIC; 
	Data_in   : in  STD_LOGIC;
    Channel   : out STD_LOGIC_VECTOR(7 downto 0);
    note : out STD_LOGIC_VECTOR(7 downto 0);
    Velocity  : out STD_LOGIC_VECTOR(7 downto 0);
    SCI_done    : out STD_LOGIC 
);
end component;
    
    
    -- signals
    signal clk        : std_logic := '0';
    signal Data_in    : std_logic := '1'; -- idle line is '1'
    signal Channel    : std_logic_vector(7 downto 0);
    signal Frequency  : std_logic_vector(7 downto 0);
    signal Velocity   : std_logic_vector(7 downto 0);
    signal SCI_done_tb   : std_logic := '0';

    -- constants
    constant CLK_PERIOD  : time := 100 ns;   -- 10 MHz
    constant BAUD_PERIOD : time := 32 us;   -- 320 cycles @ 10 MHz = 32 us per bit

    -- procedure declaration (must be inside declarative region of architecture)
procedure send_byte(signal din : out std_logic; data : std_logic_vector(7 downto 0)) is
begin
    -- start bit
    din <= '0';
    wait for BAUD_PERIOD;

    -- data bits (LSB first, unrolled)
    din <= data(0);
    wait for BAUD_PERIOD;

    din <= data(1);
    wait for BAUD_PERIOD;

    din <= data(2);
    wait for BAUD_PERIOD;

    din <= data(3);
    wait for BAUD_PERIOD;

    din <= data(4);
    wait for BAUD_PERIOD;

    din <= data(5);
    wait for BAUD_PERIOD;

    din <= data(6);
    wait for BAUD_PERIOD;

    din <= data(7);
    wait for BAUD_PERIOD;

    -- stop bit
    din <= '1';
    wait for BAUD_PERIOD;
end procedure;

begin
    -- UUT instantiation
    uut: sci
        port map (
            clk       => clk,
            Data_in   => Data_in,
            Channel   => Channel,
            Note => Frequency,
            Velocity  => Velocity,
            SCI_done => SCI_done_tb
        );

    -- clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- stimulus
    stim_proc: process
    begin
        wait for 200 us; -- allow reset/idle

        -- send three bytes: Channel=0x11, Frequency=0x22, Velocity=0x33
        send_byte(Data_in, x"ff");
        wait for 200 us;
        send_byte(Data_in, x"d4");
        wait for 200 us;
        send_byte(Data_in, x"3a");
        wait for 200 us;
        wait for 500 us;
        send_byte(Data_in, x"44");
        send_byte(Data_in, x"55");
        send_byte(Data_in, x"66");
 
        wait;
    end process;

end architecture sim;
