-- Testbench for Scaler (18-bit linear multiplier, FSM version)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Scaler is
end tb_Scaler;

architecture sim of tb_Scaler is
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
    
    -- DUT signals
    signal clk           : std_logic := '0';
    signal New_signal_in : std_logic := '0';
    signal Velocity      : std_logic_vector(7 downto 0) := (others => '0');
    signal Voltage_in    : std_logic_vector(11 downto 0) := (others => '0');
    signal Voltage_out   : std_logic_vector(11 downto 0);
    signal New_signal_out: std_logic;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin
    -- DUT instantiation
    uut: Scaler
        port map(
            clk            => clk,
            New_signal_in  => New_signal_in,
            Velocity       => Velocity,
            Voltage_in     => Voltage_in,
            Voltage_out    => Voltage_out,
            New_signal_out => New_signal_out
        );

    -- Clock generation
    clk_process : process
    begin
        while now < 10000 ns loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc : process
        procedure run_test(v_in : integer; vel : integer) is
            variable expected : integer;
        begin
            -- Apply inputs
            Velocity   <= std_logic_vector(to_unsigned(vel,8));
            Voltage_in <= std_logic_vector(to_unsigned(v_in,12));

            -- Pulse New_signal_in
            New_signal_in <= '1';
            wait for CLK_PERIOD;
            New_signal_in <= '0';

            -- Wait until FSM asserts done
            wait until rising_edge(clk) and New_signal_out = '1';

            -- small gap before next test
            wait for 5*CLK_PERIOD;
        end procedure;
    begin

        wait for 100 ns;

        -- Run multiple test cases
        run_test(3075, 25);
        run_test(255, 10);

        wait;
    end process;
end sim;
