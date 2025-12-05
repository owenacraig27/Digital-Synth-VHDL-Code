library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_notecounter is
end tb_notecounter;

architecture sim of tb_notecounter is

    component notecounter
        port (
            clk        : in std_logic;
            ch_sig     : in std_logic_vector(7 downto 0);
            done       : in std_logic;
            numnotes   : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk      : std_logic := '0';
    signal ch_sig   : std_logic_vector(7 downto 0) := (others => '0');
    signal done     : std_logic := '0';
    signal numnotes : std_logic_vector(1 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: notecounter
        port map (
            clk      => clk,
            ch_sig   => ch_sig,
            done     => done,
            numnotes => numnotes
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        wait for 20 ns;

        ----------------------------------------------------------------------
        -- SCI Transaction 1: NOTE ON (ch_sig(4) = '1')
        ----------------------------------------------------------------------
        ch_sig <= "10010000";  -- Bit 4 = '1' ? note on
        wait for clk_period;
        done <= '1';           -- Done signal goes high for 1 cycle
        wait for clk_period;
        done <= '0';

        wait for 30 ns;

        ----------------------------------------------------------------------
        -- SCI Transaction 2: NOTE ON
        ----------------------------------------------------------------------
        ch_sig <= "10010000";  -- Another note on
        wait for clk_period;
        done <= '1';
        wait for clk_period;
        done <= '0';

        wait for 30 ns;

        ----------------------------------------------------------------------
        -- SCI Transaction 3: NOTE OFF (ch_sig(4) = '0')
        ----------------------------------------------------------------------
        ch_sig <= "10000000";  -- Bit 4 = '0' ? note off
        wait for clk_period;
        done <= '1';
        wait for clk_period;
        done <= '0';

        wait for 30 ns;

        ----------------------------------------------------------------------
        -- SCI Transaction 4: NOTE OFF
        ----------------------------------------------------------------------
        ch_sig <= "10000000";
        wait for clk_period;
        done <= '1';
        wait for clk_period;
        done <= '0';

        wait for 30 ns;

        ----------------------------------------------------------------------
        -- SCI Transaction 5: Mixed content, note ON again
        ----------------------------------------------------------------------
        ch_sig <= "10010000";  -- bit 4 still = '1'
        wait for clk_period;
        done <= '1';
        wait for clk_period;
        done <= '0';

        wait for 30 ns;

        ----------------------------------------------------------------------
        -- SCI Transaction 6: Random byte, bit 4 = '0' ? note OFF
        ----------------------------------------------------------------------
        ch_sig <= "10101111";
        wait for clk_period;
        done <= '1';
        wait for clk_period;
        done <= '0';

        wait;

    end process;

end architecture sim;
