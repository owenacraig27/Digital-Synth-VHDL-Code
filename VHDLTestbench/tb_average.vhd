library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_average is
end tb_average;

architecture sim of tb_average is

    component average
        port (
            clk            : in  std_logic;
            volt1_in       : in  std_logic_vector(11 downto 0);
            volt2_in       : in  std_logic_vector(11 downto 0);
            notenum        : in  std_logic_vector(1 downto 0);
            new_signal1    : in  std_logic;
            new_signal2    : in  std_logic;
            volt_out       : out std_logic_vector(11 downto 0);
            new_signal_out : out std_logic
        );
    end component;

    -- Signals
    signal clk            : std_logic := '0';
    signal volt1_in       : std_logic_vector(11 downto 0) := (others => '0');
    signal volt2_in       : std_logic_vector(11 downto 0) := (others => '0');
    signal notenum        : std_logic_vector(1 downto 0) := "00";
    signal new_signal1    : std_logic := '0';
    signal new_signal2    : std_logic := '0';
    signal volt_out       : std_logic_vector(11 downto 0);
    signal new_signal_out : std_logic;

    constant clk_period : time := 10 ns;

begin

    ----------------------------------------------------------------------
    -- DUT Instance
    ----------------------------------------------------------------------
    uut: average
        port map (
            clk            => clk,
            volt1_in       => volt1_in,
            volt2_in       => volt2_in,
            notenum        => notenum,
            new_signal1    => new_signal1,
            new_signal2    => new_signal2,
            volt_out       => volt_out,
            new_signal_out => new_signal_out
        );

    ----------------------------------------------------------------------
    -- Clock Process
    ----------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    ----------------------------------------------------------------------
    -- Stimulus Process (desynchronized new_signals)
    ----------------------------------------------------------------------
    stim_proc : process
    begin
        wait for 20 ns;

        ----------------------------------------------------------------------
        -- Test 1: notenum = 2, volt1 first, slight delay before volt2 signal
        ----------------------------------------------------------------------
        notenum <= "10";
        volt1_in <= x"800";  -- 2048 >> 1 = 1024
        volt2_in <= x"400";  -- 1024 >> 1 = 512

        new_signal1 <= '1';       -- volt1 signal comes first
        wait for clk_period;
        new_signal1 <= '0';

        wait for 20 ns;           -- delay before volt2 signal
        new_signal2 <= '1';
        wait for clk_period;
        new_signal2 <= '0';

        wait for 60 ns;

        ----------------------------------------------------------------------
        -- Test 2: volt2 signal first this time
        ----------------------------------------------------------------------
        notenum <= "10";
        volt1_in <= x"A00";  -- 2560 >> 1 = 1280
        volt2_in <= x"600";  -- 1536 >> 1 = 768

        new_signal2 <= '1';       -- volt2 signal comes first
        wait for clk_period;
        new_signal2 <= '0';

        wait for 15 ns;
        new_signal1 <= '1';
        wait for clk_period;
        new_signal1 <= '0';

        wait for 60 ns;

        ----------------------------------------------------------------------
        -- Test 3: notenum = 1 (only volt1 used), with only new_signal1
        ----------------------------------------------------------------------
        notenum <= "01";
        volt1_in <= x"900";  -- 2304
        volt2_in <= (others => '0');

        new_signal1 <= '1';
        wait for clk_period;
        new_signal1 <= '0';

        wait for 60 ns;

        ----------------------------------------------------------------------
        -- Test 4: notenum = 1 (only volt2 used), with only new_signal2
        ----------------------------------------------------------------------
        notenum <= "01";
        volt1_in <= (others => '0');
        volt2_in <= x"700";  -- 1792

        new_signal2 <= '1';
        wait for clk_period;
        new_signal2 <= '0';

        wait for 60 ns;

        ----------------------------------------------------------------------
        -- End
        ----------------------------------------------------------------------
        wait;
    end process;

end architecture sim;
