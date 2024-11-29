--
-- Written by
--    Olaf 'Rhialto' Seibert <rhialto@falu.nl> 2024
--
-- *  This program is free software; you can redistribute it and/or modify
-- *  it under the terms of the GNU Lesser General Public License as
-- *  published by the Free Software Foundation; either version 3 of the
-- *  License, or (at your option) any later version.
-- *
-- *  This program is distributed in the hope that it will be useful,
-- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
-- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- *  GNU General Public License for more details.
-- *
-- *  You should have received a copy of the GNU Lesser General Public License
-- *  along with this program; if not, write to the Free Software
-- *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
-- *  02111-1307  USA.
--
-- Use the lowpass filter pattern where the main part is
--
--  prev = prev + alpha * (next - prev);
--
-- where alpha = 2^(-n) for easy calculation.

-- With a sample frequency of 1 MHz,
-- / 16 results in a "cutoff" frequency of ~ 10609
-- / 32 results in a "cutoff" frequency of ~ 5123
-- / 64 results in a "cutoff" frequency of ~ 2509

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity lowpass is
    generic (
             DIVISOR      : in  integer := 32;
             N            : in  integer := 3
    );
    port (
             clock        : in  std_logic;
             sample_clock : in  std_logic;
             sample_bit   : in  std_logic;
             sample_out   : out signed(15 downto 0)
    );
end lowpass;

architecture behavioural of lowpass is

    subtype sample_t is integer range 0 to 65535;
    type sample_array_t is array (N - 1 downto 0) of sample_t;

    signal prev : sample_array_t := (others => 0);

begin
    process (clock) is
        variable nxt  : sample_t;
        variable diff : integer  range -65536 to 65535;
    begin
        if rising_edge(clock) then
            if sample_clock='1' then
                sample_out <= to_signed(prev(N-1) / 2, 16) - 16384;

                nxt := 0      when sample_bit = '0' else
                       65535;

                if (N > 1) then
                    for i in N-1 downto 1 loop
                        diff := prev(i-1) - prev(i);
                        prev(i) <= prev(i) + diff / DIVISOR;
                    end loop;
                end if;

                diff := nxt - prev(0);
                prev(0) <= prev(0) + diff / DIVISOR;
            end if;
        end if;
    end process;
end behavioural;
