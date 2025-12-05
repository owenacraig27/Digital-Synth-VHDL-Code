----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2025 10:51:32 PM
-- Design Name: 
-- Module Name: FINAL_TB - Behavioral
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

entity FINAL_TB is
--  Port ( );
end FINAL_TB;

architecture Behavioral of FINAL_TB is

component FINAL_FINAL_SHELL is
  Port (clk_ext_port    : in std_logic;
        sci_in          : in std_logic ;
        spi_data         : out std_logic ;
        spi_clk         : out std_logic;
        spi_cs          : out std_logic);
end component;

signal clk_tb : std_logic := '0';
signal sci_in_tb : std_logic := '0';
signal spi_data_tb : std_logic := '0';
signal spi_clk_tb : std_logic := '0';
signal spi_cs_tb : std_logic := '0';





      
  -- constants
    constant CLK_PERIOD  : time := 10 ns;   -- 10 MHz
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
uut : FINAL_FINAL_SHELL  
port map(clk_ext_port => clk_tb ,
         sci_in       =>    sci_in_tb  ,    
         spi_data     =>   spi_data_tb ,    
         spi_clk      =>   spi_clk_tb ,     
         spi_cs       =>   spi_cs_tb  );

    -- clock generation
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- stimulus
    stim_proc: process
    begin
        wait for 500 us; -- allow reset/idle

        -- send three bytes: Channel=0x11, Frequency=0x22, Velocity=0x33
        send_byte(sci_in_tb, x"90");
        wait for 100 us;
        send_byte(sci_in_tb, x"18");
        wait for 100 us;
        send_byte(sci_in_tb, x"64");
        wait for 100 us;
        send_byte(sci_in_tb, x"90");
        send_byte(sci_in_tb, x"29");
        send_byte(sci_in_tb, x"40");
        
        wait for 200 us;
        
        send_byte(sci_in_tb, x"80");
        wait for 100 us;
        send_byte(sci_in_tb, x"18");
        wait for 100 us;
        send_byte(sci_in_tb, x"00");
        wait for 100 us;
        
        send_byte(sci_in_tb, x"80");
        wait for 100 us;
        send_byte(sci_in_tb, x"29");
        wait for 100 us;
        send_byte(sci_in_tb, x"00");
        wait for 100 us;
 
        
       wait;
    end process;






 

end Behavioral;
