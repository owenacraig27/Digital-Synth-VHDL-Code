-- =========================================================
-- Testbench for MIDI_SPI
-- =========================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_MIDI_SPI is
end tb_MIDI_SPI;

architecture sim of tb_MIDI_SPI is

    -- DUT signals
    signal clk         : std_logic := '0';
    signal Parallel_in : std_logic_vector(11 downto 0) := (others => '0');
    signal New_Signal  : std_logic := '0';
    signal CS_Out      : std_logic;
    signal Serial_out  : std_logic;

    -- clock period
    constant CLK_PERIOD : time := 10 ns;

begin
    ------------------------------------------------------------------
    -- DUT instantiation
    ------------------------------------------------------------------
    DUT: entity work.MIDI_SPI
        port map (
            clk         => clk,
            Parallel_in => Parallel_in,
            New_Signal  => New_Signal,
            CS_Out      => CS_Out,
            Serial_out  => Serial_out
        );

    ------------------------------------------------------------------
    -- Clock process
    ------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- Stimulus process
    ------------------------------------------------------------------
    stim_proc: process
    begin
        -- Initial wait
        wait for 100 ns;

        -- First transfer
        Parallel_in <= "101010101010";  -- example 12-bit pattern
        New_Signal <= '1';
        wait for CLK_PERIOD;
        New_Signal <= '0';

        -- Wait until transfer done
        wait for 400 ns;  

        -- Second transfer
        Parallel_in <= "110011001100";  
        New_Signal <= '1';
        wait for CLK_PERIOD;
        New_Signal <= '0';

        wait for 400 ns;

        -- Third transfer
        Parallel_in <= "000111000111";  
        New_Signal <= '1';
        wait for CLK_PERIOD;
        New_Signal <= '0';

        wait for 500 ns;

        -- End simulation
        wait;
    end process stim_proc;

end sim;
