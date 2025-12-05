----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/19/2025 11:11:32 PM
-- Design Name: 
-- Module Name: sine_tb - Behavioral
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




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sinewave is
end tb_sinewave;

architecture behavior of tb_sinewave is

  -- Component under test (CUT)
  component sinewave
    port (
      clk      : in std_logic;
      freq     : in std_logic_vector(9 downto 0);
      en     : in std_logic;
      pval     : out std_logic_vector(11 downto 0);
      new_pval  : out std_logic 
    );
  end component;

  -- Signals
  signal clk_tb      : std_logic := '0';
  signal freq_tb     : std_logic_vector(9 downto 0) := (others => '0');
  signal en_tb : std_logic := '0';
  signal new_pval_tb     : std_logic := '0';
  signal pval_tb     : std_logic_vector(11 downto 0);

  -- Clock period (e.g., 100ns = 10MHz)
  constant clk_period : time := 100 ns;

begin

  -- Instantiate the unit under test
  uut: sinewave
    port map (
      clk      => clk_tb,
      freq     => freq_tb,
      en     => en_tb,
      pval     => pval_tb,
      new_pval => new_pval_tb 
    );

  -- Clock generation process
  clk_process : process
  begin
    while true loop
      clk_tb <= '0';
      wait for clk_period / 2;
      clk_tb <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
    -- Initialize
    en_tb <= '0';
    wait for 10 ns;


    -- Set frequency and load it
    freq_tb <= std_logic_vector(to_unsigned(800, 10));  -- Frequency step size
    en_tb <= '1';

    -- Let it run for some time
    wait for 2000 ns;

   
    wait;
  end process;

end behavior;
