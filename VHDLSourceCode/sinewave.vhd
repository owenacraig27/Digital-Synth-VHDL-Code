----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/19/2025 07:13:28 PM
-- Design Name: 
-- Module Name: sinewave - Behavioral
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

entity sinewave is
Port (clk   : in std_logic; 
      freq  :  in STD_LOGIC_VECTOR(9 downto 0);
      en    : in std_logic;
      pval : out std_logic_vector (11 downto 0);
      new_pval : out std_logic);
end sinewave;

 architecture Behavioral of sinewave is

    constant TC : unsigned (10 downto 0) := to_unsigned(153,11);
    signal fstored : std_logic_vector(9 downto 0):= (others => '0');
    signal addr_cnt : std_logic_vector(15 downto 0):= (others => '0');
    signal sample_cnt : unsigned(10 downto 0) := (others => '0');
    signal sample_tc : std_logic := '0';
    signal valid_in : std_logic := '0';
    signal p_Lut : std_logic_vector(11 downto 0) := (others => '0');
    signal p_en : std_logic := '0'; 
    signal rom_data : std_logic_vector (15 downto 0);
    signal clr_wave :  std_logic := '1';
    
    -- declaring DDS IP block
    component dds_compiler_0 IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;
    
begin

-- asynchronous assignments 
clr_wave <= not(en);
new_pval <= p_en;

-- instantiate DDS block
 u_dds :  dds_compiler_0
    port map (
      aclk => clk,
      s_axis_phase_tvalid => valid_in,
      s_axis_phase_tdata  => addr_cnt ,
      m_axis_data_tvalid  => p_en,
      m_axis_data_tdata   => rom_data 
    );
-- stored frequency flipflop:
process(clk) begin
    if rising_edge(clk) then
        if(en = '1') then fstored<=freq;
        end if;
    end if;
end process;


-- addres step adder 
process( clk) begin 
    if rising_edge(clk) then 
        if(clr_wave = '1') then addr_cnt <= (others => '0');
        else
            if (sample_tc = '1') then
                if (clr_wave = '1') then addr_cnt  <= (others=> '0');
                else addr_cnt  <= std_logic_vector(unsigned(addr_cnt) + unsigned(fstored)) ;
                end if;
            end if;
        end if;
    end if;
end process;

-- data valid flipflop 
process (clk) begin
    if (rising_edge (clk)) then 
        valid_in <= sample_tc;
    end if;
end process;

-- voltage output flipflop 
process (clk) begin
    if rising_edge(clk) then
        if (en = '1') then
            if (p_en = '1') then -- add 2048 to make wave all positive unsigned
                pval <= std_logic_vector(to_unsigned(2048,12)+unsigned(rom_data(11 downto 0)));    
            end if;
        else
            pval <= (others => '0');
        end if;
    end if;
end process;

-- sample timer 
process(clk) begin
if rising_edge(clk) then
    if (sample_tc = '1') then 
        sample_cnt <= (others => '0');
    else
        sample_cnt <= sample_cnt + 1;
    end if;
end if;
end process;

--sample tc process 
process(sample_cnt, en ) begin
    if(sample_cnt = TC-1 and en = '1') then
         sample_TC <= '1';
    else sample_TC <= '0';
    end if; 
end process; 
  


            
end Behavioral;
  