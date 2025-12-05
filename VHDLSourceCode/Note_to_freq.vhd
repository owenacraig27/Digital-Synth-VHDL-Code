----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2025 10:07:02 PM
-- Design Name: 
-- Module Name: Note_to_freq - Behavioral
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

entity note2f is
  Port (note_ext    : in unsigned(7 downto 0);
        freq_ext    : out unsigned (9 downto 0) );
end note2f;

architecture Behavioral of note2f is


begin
process( note_ext) begin 
    case note_ext is
    
    
    -- OCTAVE 1
    
        when to_unsigned(12,8)=> -- C2
            freq_ext<= to_unsigned(32, 10);
       when to_unsigned(13,8)=> -- C#2
            freq_ext<= to_unsigned(34, 10);
        when to_unsigned(14,8)=> -- D2
            freq_ext<= to_unsigned(36, 10);
        when to_unsigned(15,8)=> -- D#2
            freq_ext<= to_unsigned(38, 10);
        when to_unsigned(16,8)=> --E2
            freq_ext<= to_unsigned(41, 10);
        when to_unsigned(17,8)=> --F2
            freq_ext<= to_unsigned(43, 10);
        when to_unsigned(18,8)=> --F#2
            freq_ext<= to_unsigned(46, 10);
        when to_unsigned(19,8)=> -- G2
            freq_ext<= to_unsigned(49, 10);
        when to_unsigned(20,8)=> -- G#2
            freq_ext<= to_unsigned(52, 10);
        when to_unsigned(21,8)=> --A2
            freq_ext<= to_unsigned(55, 10);
        when to_unsigned(22,8)=> --A#2
            freq_ext<= to_unsigned(58, 10);
        when to_unsigned(23,8)=> --B2
            freq_ext<= to_unsigned(61, 10);
    
-- OCTAVE 2
    
        when to_unsigned(24,8)=> -- C2
            freq_ext<= to_unsigned(65, 10);
       when to_unsigned(25,8)=> -- C#2
            freq_ext<= to_unsigned(69, 10);
        when to_unsigned(26,8)=> -- D2
            freq_ext<= to_unsigned(73, 10);
        when to_unsigned(27,8)=> -- D#2
            freq_ext<= to_unsigned(77, 10);
        when to_unsigned(28,8)=> --E2
            freq_ext<= to_unsigned(82, 10);
        when to_unsigned(29,8)=> --F2
            freq_ext<= to_unsigned(87, 10);
        when to_unsigned(30,8)=> --F#2
            freq_ext<= to_unsigned(92, 10);
        when to_unsigned(31,8)=> -- G2
            freq_ext<= to_unsigned(98, 10);
        when to_unsigned(32,8)=> -- G#2
            freq_ext<= to_unsigned(104, 10);
        when to_unsigned(33,8)=> --A2
            freq_ext<= to_unsigned(110, 10);
        when to_unsigned(34,8)=> --A#2
            freq_ext<= to_unsigned(116, 10);
        when to_unsigned(35,8)=> --B2
            freq_ext<= to_unsigned(123, 10);
            
-- OCTAVE 3


        when to_unsigned(36,8)=> --C
            freq_ext<= to_unsigned(130, 10);
       when to_unsigned(37,8)=> -- C#
            freq_ext<= to_unsigned(138, 10);
        when to_unsigned(38,8)=> -- D
            freq_ext<= to_unsigned(146, 10);
        when to_unsigned(39,8)=> -- D#
            freq_ext<= to_unsigned(155, 10);
        when to_unsigned(40,8)=> --E
            freq_ext<= to_unsigned(164, 10);
        when to_unsigned(41,8)=> --F
            freq_ext<= to_unsigned(174, 10);
        when to_unsigned(42,8)=> --F#
            freq_ext<= to_unsigned(185, 10);
        when to_unsigned(43,8)=> -- G
            freq_ext<= to_unsigned(196, 10);
        when to_unsigned(44,8)=> -- G#
            freq_ext<= to_unsigned(208, 10);
        when to_unsigned(45,8)=> --A
            freq_ext<= to_unsigned(220, 10);
        when to_unsigned(46,8)=> --A#
            freq_ext<= to_unsigned(233, 10);
        when to_unsigned(47,8)=> --B
            freq_ext<= to_unsigned(246, 10);
   
   -- OCTAVE 4
                      
        when to_unsigned(48,8)=> --C
            freq_ext<= to_unsigned(261, 10);
       when to_unsigned(49,8)=> -- C#
            freq_ext<= to_unsigned(277, 10);
        when to_unsigned(50,8)=> -- D
            freq_ext<= to_unsigned(293, 10);
        when to_unsigned(51,8)=> -- D#
            freq_ext<= to_unsigned(311, 10);
        when to_unsigned(52,8)=> --E
            freq_ext<= to_unsigned(329, 10);
        when to_unsigned(53,8)=> --F
            freq_ext<= to_unsigned(349, 10);
        when to_unsigned(54,8)=> --F#
            freq_ext<= to_unsigned(369, 10);
        when to_unsigned(55,8)=> -- G
            freq_ext<= to_unsigned(392, 10);
        when to_unsigned(56,8)=> -- G#
            freq_ext<= to_unsigned(415, 10);
        when to_unsigned(57,8)=> --A
            freq_ext<= to_unsigned(440, 10);
        when to_unsigned(58,8)=> --A#
            freq_ext<= to_unsigned(466, 10);
        when to_unsigned(59,8)=> --B
            freq_ext<= to_unsigned(493, 10);
            
-- octave 5  
            
        when to_unsigned(60,8)=> --C
            freq_ext<= to_unsigned(523, 10);
       when to_unsigned(61,8)=> -- C#
            freq_ext<= to_unsigned(554, 10);
        when to_unsigned(62,8)=> -- D
            freq_ext<= to_unsigned(587, 10);
        when to_unsigned(63,8)=> -- D#
            freq_ext<= to_unsigned(622, 10);
        when to_unsigned(64,8)=> --E
            freq_ext<= to_unsigned(659, 10);
        when to_unsigned(65,8)=> --F
            freq_ext<= to_unsigned(698, 10);
        when to_unsigned(66,8)=> --F#
            freq_ext<= to_unsigned(739, 10);
        when to_unsigned(67,8)=> -- G
            freq_ext<= to_unsigned(784, 10);
        when to_unsigned(68,8)=> -- G#
            freq_ext<= to_unsigned(830, 10);
        when to_unsigned(69,8)=> --A
            freq_ext<= to_unsigned(880, 10);
        when to_unsigned(70,8)=> --A#
            freq_ext<= to_unsigned(932, 10);
        when to_unsigned(71,8)=> --B
            freq_ext<= to_unsigned(987, 10);
            
            
         when others => 
            freq_ext<= to_unsigned(0, 10);  
    end case;
end process;

end Behavioral;
