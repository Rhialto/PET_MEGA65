----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;
use work.vdrives_pkg.all;
use work.globals.QNICE_CLK_SPEED;
use work.globals.C_MENU_MODEL_2001_BLANK;
use work.globals.C_MENU_MODEL_2001_WHITE;
use work.globals.C_MENU_MODEL_CRTC;
use work.globals.C_MENU_MODEL_B_KEYBOARD;
use work.globals.C_MENU_MODEL_80_COLUMNS;
use work.globals.C_MENU_MODEL_COLOUR_PET;
use work.globals.C_MENU_MODEL_08_KB;
use work.globals.C_MENU_MODEL_16_KB;
use work.globals.C_MENU_MODEL_32_KB;
use work.globals.C_MENU_MODEL_8096_MEM;
use work.globals.C_MENU_MODEL_8296_MEM;

use work.globals.C_VD_SUBDRIVES;


entity main is
   generic (
      G_VDNUM                 : natural         -- amount of virtual drives: C_VD_UNITS * C_VD_SUBDRIVES
   );
   port (
      clk_main_i              : in  std_logic;  -- 32 MHz
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;

      -- On-screen-menu selection
      osm_i                   : in  std_logic_vector(255 downto 0);

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      -- Video output
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(7 downto 0);
      video_green_o           : out std_logic_vector(7 downto 0);
      video_blue_o            : out std_logic_vector(7 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- floppy drive led (color is RGB)
      drive_led_o            : out std_logic;
      drive_led_col_o        : out std_logic_vector(23 downto 0);
      drive_cache_dirty      : out std_logic;

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0);

      -- C64 IEC handled by QNICE
      pet_clk_sd_i           : in  std_logic;                -- QNICE "sd card write clock" for floppy drive internal dual clock RAM buffer
      pet_qnice_addr_i       : in  std_logic_vector(27 downto 0);
      pet_qnice_data_i       : in  std_logic_vector(15 downto 0);
      pet_qnice_data_o       : out std_logic_vector(15 downto 0);
      pet_qnice_ce_i         : in  std_logic;
      pet_qnice_we_i         : in  std_logic;

		-- Access custom Kernal: PET's Basic and character ROM (in QNICE clock domain via pet_clk_sd_i)
      petrom_we_i            : in  std_logic;
      petchars_ce_i          : in  std_logic;
      petrom_addr_i          : in  std_logic_vector(14 downto 0);
      petrom_data_i          : in  std_logic_vector(7 downto 0);
      petrom_data_o          : out std_logic_vector(7 downto 0);

      -- Access custom DOS for the simulated C2031 (in QNICE clock domain via pet_clk_sd_i)
      c2031rom_we_i          : in  std_logic;
      c2031rom_addr_i        : in  std_logic_vector(15 downto 0);
      c2031rom_data_i        : in  std_logic_vector(7 downto 0);
      c2031rom_data_o        : out std_logic_vector(7 downto 0)
   );
end entity main;

architecture synthesis of main is

   -- Generic MiSTer PET signals
   --signal pet_pause          : std_logic;
    signal pet_drive_act_led   : vd_vec_array(G_VDNUM/C_VD_SUBDRIVES - 1 downto 0)(C_VD_SUBDRIVES-1 downto 0);
    signal pet_drive_err_led   : std_logic_vector(G_VDNUM/C_VD_SUBDRIVES-1 downto 0);

    signal cnt31 : INTEGER range 0 to 31 := 0;        -- 5 bits
    signal ce_1m : STD_LOGIC;

    signal addr : std_logic_vector(15 downto 0);
    signal addr_unused : std_logic_vector(23 downto 16);
    signal cpu_data_out : std_logic_vector(7 downto 0);
    signal cpu_data_in : std_logic_vector(7 downto 0);
    signal rnw : std_logic;
    signal irq : std_logic;

    signal pix : std_logic;
    signal HBlank : std_logic;
    signal VBlank : std_logic;
    signal audioDat : std_logic ;
    signal tape_audio : std_logic;

    -- Directly connect the PET's PIA1 to the emulated keyboard matrix within keyboard.vhd
    signal keyb_row_select : std_logic_vector(3 downto 0);
    signal keyb_column_selected : std_logic_vector(7 downto 0);
    signal diag_sense : std_logic;

    -- PET's IEEE connector to the bus
    signal ieee488_pet_data_i  : std_logic_vector(7 downto 0);
    signal ieee488_pet_data_o  : std_logic_vector(7 downto 0);
    signal ieee488_pet_atn_i   : std_logic;
    signal ieee488_pet_atn_o   : std_logic;
    signal ieee488_pet_ifc_o   : std_logic;
    signal ieee488_pet_srq_i   : std_logic;
    signal ieee488_pet_dav_i   : std_logic;
    signal ieee488_pet_dav_o   : std_logic;
    signal ieee488_pet_eoi_i   : std_logic;
    signal ieee488_pet_eoi_o   : std_logic;
    signal ieee488_pet_nrfd_i  : std_logic;
    signal ieee488_pet_nrfd_o  : std_logic;
    signal ieee488_pet_ndac_i  : std_logic;
    signal ieee488_pet_ndac_o  : std_logic;

    -- The disk's IEEE connector to the bus
    signal ieee488_d01_data_i  : std_logic_vector(7 downto 0);
    signal ieee488_d01_data_o  : std_logic_vector(7 downto 0);
    signal ieee488_d01_atn_i   : std_logic;
    signal ieee488_d01_atn_o   : std_logic;
    signal ieee488_d01_ifc_i   : std_logic;
    signal ieee488_d01_srq_o   : std_logic;
    signal ieee488_d01_dav_i   : std_logic;
    signal ieee488_d01_dav_o   : std_logic;
    signal ieee488_d01_eoi_i   : std_logic;
    signal ieee488_d01_eoi_o   : std_logic;
    signal ieee488_d01_nrfd_i  : std_logic;
    signal ieee488_d01_nrfd_o  : std_logic;
    signal ieee488_d01_ndac_i  : std_logic;
    signal ieee488_d01_ndac_o  : std_logic;

   -- Simulated IEEE-488 drives
   signal iec_drive_ce         : std_logic;      -- chip enable for iec_drive (clock divider, see generate_drive_ce below)
   signal iec_dce_sum          : integer := 0;   -- caution: we expect 32-bit integers here and we expect the initialization to 0

   signal iec_img_mounted      : std_logic_vector(G_VDNUM - 1 downto 0);
   signal iec_img_readonly     : std_logic;
   signal iec_img_size         : std_logic_vector(31 downto 0);
   signal iec_img_type         : std_logic_vector( 1 downto 0);

   signal iec_drives_reset     : std_logic_vector(G_VDNUM - 1 downto 0);
   signal vdrives_mounted      : std_logic_vector(G_VDNUM - 1 downto 0);
   signal cache_dirty          : std_logic_vector(G_VDNUM - 1 downto 0);
   signal prevent_reset        : std_logic;

   signal iec_sd_lba           : vd_vec_array(G_VDNUM - 1 downto 0)(31 downto 0);
   signal iec_sd_blk_cnt       : vd_vec_array(G_VDNUM - 1 downto 0)( 5 downto 0);
   signal iec_sd_rd            : vd_std_array(G_VDNUM - 1 downto 0);
   signal iec_sd_wr            : vd_std_array(G_VDNUM - 1 downto 0);
   signal iec_sd_ack           : vd_std_array(G_VDNUM - 1 downto 0);
   signal iec_sd_buf_addr      : std_logic_vector(13 downto 0);
   signal iec_sd_buf_data_in   : std_logic_vector( 7 downto 0);
   signal iec_sd_buf_data_out  : vd_vec_array(G_VDNUM - 1 downto 0)(7 downto 0);
   signal iec_sd_buf_wr        : std_logic;
   --signal iec_par_stb_in       : std_logic;
   --signal iec_par_stb_out      : std_logic;
   --signal iec_par_data_in      : std_logic_vector(7 downto 0);
   --signal iec_par_data_out     : std_logic_vector(7 downto 0);

   -- RESET SEMANTICS
   --
   -- The C64 core implements core specific semantics: A standard reset of the core is a soft reset and
   -- will not interfere with any "reset protections". This also means that a soft reset will start
   -- soft- and hardware cartridges. A hard reset on the other hand does circumvent "reset protections"
   -- and will therefore also exit games which prevent you from exitting them via reset and you can
   -- also exit from simulated cartridges using a hard reset.
   --
   -- When pulsing reset_soft_i from the outside (mega65.vhd), then you need to ensure that this
   -- pulse is at least 32 clock cycles long. Currently (see mega65.vhd) there are two sources that
   -- trigger reset_soft_i: The M2M reset manager and sw_cartridge_wrapper. Both are ensuring that
   -- the rest pulse is at least 32 clock cycles long.
   --
   -- A reset that is coming from a hardware cartridge via cart_reset_i (which is low active) is treated
   -- just like reset_soft_i. We can assume that the pulse will be long enough because cartridges are
   -- aware of minimum reset durations. (Example: The EF3 pulses the reset for 7xphi2, which is way longer
   -- then 32 cycles.)
   --
   -- CAUTION: NEVER DIRECTLY USE THE INPUT SIGNALS
   --       reset_soft_i and
   --       reset_hard_i
   -- IN MAIN.VHD AS YOU WILL RISK DATA CORRUPTION!
   -- Exceptions are the processes "hard_reset" and "handle_cartridge_triggered_resets",
   -- which "know what they are doing".
   --
   -- The go-to signal for all standard reset situations within main.vhd:
   --       reset_core_n
   -- To prevent data corruption, there is a protected version of reset_soft_i called reset_core_n.
   -- Data corruption can for example occur, when a user presses the reset button while a simulated
   -- disk drive is still writing to the disk image on the SD card. Therefore reset_core_n is
   -- protected by using the signal prevent_reset.
   --
   -- hard_reset_n IS NOT MEANT TO BE USED IN MAIN.VHD
   -- with the exception of the "cpu_data_in" the reset input of "i_cartridge".
   signal reset_core_n         : std_logic := '1';
   signal reset_core_int_n     : std_logic := '1';
   signal hard_reset_n         : std_logic := '1';

   constant C_HARD_RST_DELAY   : natural   := 100_000; -- roundabout 1/30 of a second
   signal hard_rst_counter     : natural   := 0;
   signal hard_reset_n_d       : std_logic := '1';
   signal cold_start_done      : std_logic := '0';

   signal sound_sample         : signed(15 downto 0);	-- low-passed sound

   signal ce_pixel             : std_logic;

   -- -- --
   -- -- --
   --
   -- Our vd_vec_arrays are typically declared as
   --   signal iec_sd_lba  : vd_vec_array(G_VDNUM - 1 downto 0)(31 downto 0);
   -- and the Verilog counterpart is
   --   output      [31:0] sd_lba[NBD],
   -- which has the opposite endianness in the first [NBD] index.
   -- So we swap here, rather than changing the whole M2M framework to use
   --   signal iec_sd_lba  : vd_vec_array(0 to G_VDNUM - 1)(31 downto 0);

   function reverse_vd_vec_array(arr : vd_vec_array) return vd_vec_array is
       variable result : vd_vec_array(arr'RANGE)(arr'element'RANGE);
   begin
       for i in arr'RANGE loop
           result(arr'HIGH - i + arr'LOW) := arr(i);
       end loop;
       return result;
   end function;

begin

   -- prevent data corruption by not allowing a soft reset to happen while the cache is still dirty
   -- since we can have more than one cache that might be dirty, we convert the std_logic_vector of length G_VDNUM
   -- into an unsigned and check for zero
   prevent_reset <= '0' when unsigned(cache_dirty) = 0 else
                    '1';

   -- the color of the power led is red normally, but it turns yellow
   -- when the cache is dirty and/or currently being flushed.
   drive_cache_dirty <= '0' when unsigned(cache_dirty) = 0 else
                        '1';
   -- The red component is active if the error LED is active
   -- The green component is active if drive 0 is active
   -- The blue component is active if drive 1 is active
   -- FIXME: activity leds for more than 1 drive.
   drive_led_col_o(23 downto 16) <= x"80" when unsigned(pet_drive_err_led) /= 0 else x"00";
   drive_led_col_o(15 downto  8) <= x"FF" when pet_drive_act_led(0)(0) = '1' else x"00";
   drive_led_col_o( 7 downto  0) <= x"FF" when pet_drive_act_led(0)(1) = '1' else x"00";

   -- the drive led is on if either drive is active, or the error LED.
   drive_led_o <=      '1' when (or pet_drive_act_led(0)) = '1' or
                                unsigned(pet_drive_err_led) /= 0
                  else '0';
   --------------------------------------------------------------------------------------------------
   -- Hard reset
   --------------------------------------------------------------------------------------------------

   hard_reset_proc : process (clk_main_i)
   begin
      if rising_edge(clk_main_i) then
         if reset_soft_i = '1' or reset_hard_i = '1'  then
            -- Due to sw_cartridge_wrapper's logic, reset_soft_i stays high longer than reset_hard_i.
            -- We need to make sure that this is not interfering with hard_reset_n
            if reset_hard_i = '1' then
               hard_rst_counter  <= C_HARD_RST_DELAY;
               hard_reset_n      <= '0';
            end if;

            -- reset_core_n is low-active, so prevent_reset = 0 means execute reset
            -- but a hard reset can override
            reset_core_int_n     <= prevent_reset and (not reset_hard_i);
         else
            -- The idea of the hard reset is, that while reset_core_n is back at '1' and therefore the core is
            -- running (not being reset any more), hard_reset_n stays low for C_HARD_RST_DELAY clock cycles.
            -- Reason: We need to give the KERNAL time to execute the routine $FD02 where it checks for the
            -- cartridge signature "CBM80" in $8003 onwards. In case reset_n = '0' during these tests (i.e. hard
            -- reset active) we will return zero instead of "CBM80" and therefore perform a hard reset.
            reset_core_int_n <= '1';
            if hard_rst_counter = 0 then
               hard_reset_n <= '1';
            else
               hard_rst_counter <= hard_rst_counter - 1;
            end if;
         end if;
      end if;
   end process hard_reset_proc;

   -- Combined reset signal to be used throughout main.vhd: reset triggered by the MEGA65's reset button (reset_core_int_n)
   -- and reset triggered by an external cartridge.
   combined_reset_proc : process (all)
   begin
      reset_core_n <= '1';

      -- cart_reset_i becomes cart_reset_o as soon as cart_reset_oe_o = '1', and the latter one becomes '1' as soon
      -- as reset_core_int_n = '0' so we need to ignore cart_reset_i in this case
      if reset_core_int_n = '0' then
         reset_core_n <= '0';
      end if;
   end process combined_reset_proc;

   -- To make sure that cartridges in the Expansion Port start properly, we must not do a hard reset and mask the $8000 memory area,
   -- when the core is launched for the first time (cold start).
   handle_cold_start_proc : process (clk_main_i)
   begin
      if rising_edge(clk_main_i) then
         hard_reset_n_d <= hard_reset_n;
         -- detect the rising edge of hard_reset_n_d
         if hard_reset_n = '1' and hard_reset_n_d = '0' and cold_start_done = '0' then
            cold_start_done <= '1';
         end if;
      end if;
   end process handle_cold_start_proc;

     -- Clock enable signals process
     process(clk_main_i)
     begin
         if rising_edge(clk_main_i) then
             -- Divide 32 MHz by 32 to get 1 MHz.
             cnt31 <= cnt31 + 1;
             if cnt31 = 31 then
                 cnt31 <= 0;
             end if;
             ce_1m <= '1' when cnt31 = 0 else '0';
         end if;
     end process;
-- 
-- end Behavioral;

----------------------------------------------------
-- RAM
-- we don't need this, all RAM and ROM is included in pet2001hw.
----------------------------------------------------

    cpu_inst : entity work.T65
        port map (
            Mode => "00", -- Assuming Mode is a 2-bit signal
            Res_n => reset_core_n,
            Enable => ce_1m,
            Clk => clk_main_i,
            Rdy => '1',
            Abort_n => '1',
            IRQ_n => not irq,
            NMI_n => '1',
            SO_n => '1',
            R_W_n => rnw,
            A(23 downto 16) => addr_unused,
            A(15 downto 0) => addr,
            DIn => cpu_data_in,
            DOut => cpu_data_out
        );

    pet2001hw_inst : entity work.pet2001hw
    port map (
        addr        => addr,
        data_out    => cpu_data_in,
        data_in     => cpu_data_out,
        we          => not rnw,
        irq         => irq,

        ce_pixel_o  => ce_pixel,
        pix_o       => pix,
        video_red_o => video_red_o,
        video_green_o => video_green_o,
        video_blue_o => video_blue_o,
        HSync_o     => video_hs_o,
        VSync_o     => video_vs_o,
        HBlank_o    => video_hblank_o,
        VBlank_o    => video_vblank_o,

        pref_eoi_blanks       => osm_i(C_MENU_MODEL_2001_BLANK),
        pref_have_2001_white  => osm_i(C_MENU_MODEL_2001_WHITE),
        pref_have_crtc        => osm_i(C_MENU_MODEL_CRTC) or osm_i(C_MENU_MODEL_80_COLUMNS) or osm_i(C_MENU_MODEL_COLOUR_PET),
        pref_have_80_cols     => osm_i(C_MENU_MODEL_80_COLUMNS),
        pref_have_colour      => osm_i(C_MENU_MODEL_COLOUR_PET),
        pref_have_08k         => osm_i(C_MENU_MODEL_08_KB),
        pref_have_16k         => osm_i(C_MENU_MODEL_16_KB),
        pref_have_32k         => osm_i(C_MENU_MODEL_32_KB),
        pref_have_8096        => osm_i(C_MENU_MODEL_8096_MEM),
        pref_have_8296        => osm_i(C_MENU_MODEL_8296_MEM),

        keyrow      => keyb_row_select,       -- keyboard scanning (row select)
        keyin       => keyb_column_selected,  -- keyboard scanning (pressed keys)

        cass_motor_n    => open,              -- output? not connected?
        cass_write      => open,              -- tape_write,
        audio           => audioDat,          -- sound from CB2: 1 MHz, 1 bit
        cass_sense_n    => 0,
        cass_read       => tape_audio,

        -- IEEE-488 bus
        ieee488_data_i  => ieee488_pet_data_i,
        ieee488_data_o  => ieee488_pet_data_o,
        ieee488_atn_i   => ieee488_pet_atn_i,
        ieee488_atn_o   => ieee488_pet_atn_o,
        ieee488_ifc_o   => ieee488_pet_ifc_o,
        ieee488_srq_i   => ieee488_pet_srq_i,
        ieee488_dav_i   => ieee488_pet_dav_i,
        ieee488_dav_o   => ieee488_pet_dav_o,
        ieee488_eoi_i   => ieee488_pet_eoi_i,
        ieee488_eoi_o   => ieee488_pet_eoi_o,
        ieee488_nrfd_i  => ieee488_pet_nrfd_i,
        ieee488_nrfd_o  => ieee488_pet_nrfd_o,
        ieee488_ndac_i  => ieee488_pet_ndac_i,
        ieee488_ndac_o  => ieee488_pet_ndac_o,

        -- QNICE clock domain via pet_clk_sd_i
        dma_clk         => pet_clk_sd_i,
        dma_addr        => petrom_addr_i,
        dma_din         => petrom_data_i,
        dma_dout        => petrom_data_o,
        dma_we          => petrom_we_i,
        dma_char_ce     => petchars_ce_i,

        clk_speed       => 0,
        clk_stop        => 0,
        diag_l          => diag_sense,
        clk             => clk_main_i,
        cnt31_i         => cnt31,
        ce_1m           => ce_1m,
        reset           => not reset_core_n
     ); -- hw_inst

    ieee488_bus : entity work.ieee488_bus_1
    port map (
        pet_data_o => ieee488_pet_data_i,
        pet_data_i => ieee488_pet_data_o,
        pet_atn_o  => ieee488_pet_atn_i,
        pet_atn_i  => ieee488_pet_atn_o,
        pet_ifc_i  => ieee488_pet_ifc_o,
        pet_srq_o  => ieee488_pet_srq_i,
        pet_dav_o  => ieee488_pet_dav_i,
        pet_dav_i  => ieee488_pet_dav_o,
        pet_eoi_o  => ieee488_pet_eoi_i,
        pet_eoi_i  => ieee488_pet_eoi_o,
        pet_nrfd_o => ieee488_pet_nrfd_i,
        pet_nrfd_i => ieee488_pet_nrfd_o,
        pet_ndac_o => ieee488_pet_ndac_i,
        pet_ndac_i => ieee488_pet_ndac_o,

        d01_data_o => ieee488_d01_data_i,
        d01_data_i => ieee488_d01_data_o,
        d01_atn_i  => ieee488_d01_atn_o,
        d01_atn_o  => ieee488_d01_atn_i,
        d01_ifc_o  => ieee488_d01_ifc_i,
        d01_srq_i  => ieee488_d01_srq_o,
        d01_dav_o  => ieee488_d01_dav_i,
        d01_dav_i  => ieee488_d01_dav_o,
        d01_eoi_o  => ieee488_d01_eoi_i,
        d01_eoi_i  => ieee488_d01_eoi_o,
        d01_nrfd_o => ieee488_d01_nrfd_i,
        d01_nrfd_i => ieee488_d01_nrfd_o,
        d01_ndac_o => ieee488_d01_ndac_i,
        d01_ndac_i => ieee488_d01_ndac_o

--        d01_data_o => open,
--        d01_data_i => (others => 'H'),
--        d01_atn_i  => 'H',
--        d01_atn_o  => open,
--        d01_ifc_o  => open,
--        d01_srq_i  => 'H',
--        d01_dav_o  => open,
--        d01_dav_i  => 'H',
--        d01_eoi_o  => open,
--        d01_eoi_i  => 'H',
--        d01_nrfd_o => open,
--        d01_nrfd_i => 'H',
--        d01_ndac_o => open,
--        d01_ndac_i => 'H'

    ); -- ieee488_bus


   -- On video_ce_o and video_ce_ovl_o: You have an important @TODO when porting a core:
   -- video_ce_o: You need to make sure that video_ce_o divides clk_main_i such that it transforms clk_main_i
   --             into the pixelclock of the core (means: the core's native output resolution pre-scandoubler)
   -- video_ce_ovl_o: Clock enable for the OSM overlay and for sampling the core's (retro) output in a way that
   --             it is displayed correctly on a "modern" analog input device: Make sure that video_ce_ovl_o
   --             transforms clk_main_o into the post-scandoubler pixelclock that is valid for the target
   --             resolution specified by VGA_DX/VGA_DY (globals.vhd)
   -- video_retro15kHz_o: '1', if the output from the core (post-scandoubler) in the retro 15 kHz analog RGB mode.
   --             Hint: Scandoubler off does not automatically mean retro 15 kHz on.
   video_ce_o <= ce_pixel;
   video_ce_ovl_o <= ce_pixel;

   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         row_select_i         => keyb_row_select,
         column_selected_o    => keyb_column_selected,
         business_layout_i    => osm_i(C_MENU_MODEL_B_KEYBOARD),

         diag_sense_o         => diag_sense
      ); -- i_keyboard

   -- Drive is held to reset if the core is held to reset or if the drive is not mounted, yet
   -- @TODO: MiSTer also allows these options when it comes to drive-enable:
   --        "P2oPQ,Enable Drive #8,If Mounted,Always,Never;"
   --        "P2oNO,Enable Drive #9,If Mounted,Always,Never;"
   --        This code currently only implements the "Always" option
   iec_drv_reset_gen : for i in 0 to G_VDNUM - 1 generate
      -- iec_drives_reset(i) <= (not reset_core_n) or (not vdrives_mounted(i));
       iec_drives_reset(i) <= (not reset_core_n); -- for now allow empty drives...
   end generate iec_drv_reset_gen;

------------------------------------------
-- Let's connect some drives!
------------------------------------------

   ieee_drive_inst : entity work.ieee_drive
      generic map (
         DRIVES         => G_VDNUM / C_VD_SUBDRIVES,
         SUBDRV         => C_VD_SUBDRIVES
      )
      port map (
         --clk            => clk_main_speed_i,
         --clk_sys        => clk_main_i,
         clk            => QNICE_CLK_SPEED,
         clk_sys        => pet_clk_sd_i,
         clk_main       => clk_main_i,
         reset          => iec_drives_reset,
         pause          => pause_i,

         -- drive led
         led_act        => pet_drive_act_led,
         led_err        => pet_drive_err_led,

         -- Device connected to IEEE-488 bus

         bus_i_atn      => ieee488_d01_atn_i,
         bus_i_eoi      => ieee488_d01_eoi_i,
         bus_i_srq      => '1',
         bus_i_ren      => '1',
         bus_i_ifc      => ieee488_d01_ifc_i,
         bus_i_dav      => ieee488_d01_dav_i,
         bus_i_ndac     => ieee488_d01_ndac_i,
         bus_i_nrfd     => ieee488_d01_nrfd_i,
         bus_i_data     => ieee488_d01_data_i,

         bus_o_atn      => ieee488_d01_atn_o,
         bus_o_eoi      => ieee488_d01_eoi_o,
         bus_o_srq      => ieee488_d01_srq_o,
         bus_o_ren      => open,
         bus_o_ifc      => open,
         bus_o_dav      => ieee488_d01_dav_o,
         bus_o_ndac     => ieee488_d01_ndac_o,
         bus_o_nrfd     => ieee488_d01_nrfd_o,
         bus_o_data     => ieee488_d01_data_o,

         drv_type       => "1",                    -- 0=8250, 1=4040 FIXME "1" for just one drive!

         -- disk image status
         img_mounted    => iec_img_mounted,
         img_size       => iec_img_size,
         img_readonly   => iec_img_readonly,

         -- QNICE SD-Card/FAT32 interface

         sd_lba         => iec_sd_lba,
         sd_blk_cnt     => iec_sd_blk_cnt,
         sd_rd          => iec_sd_rd,
         sd_wr          => iec_sd_wr,
         sd_ack         => iec_sd_ack,
         sd_buff_addr   => iec_sd_buf_addr,
         sd_buff_dout   => iec_sd_buf_data_in,   -- data from SD card to the buffer RAM within the drive ("dout" is a strange name)
         sd_buff_din    => iec_sd_buf_data_out,  -- read the buffer RAM within the drive
         sd_buff_wr     => iec_sd_buf_wr

         -- Access custom rom (DOS): All in QNICE clock domain but rom_std_i is in main clock domain
         --rom_std_i      => '1',  -- pet_rom_i(0) or pet_rom_i(1), -- 1=use the factory default ROM
         --rom_addr_i     => c2031rom_addr_i,
         --rom_data_i     => c2031rom_data_i,
         --rom_wr_i       => c2031rom_we_i,
         --rom_data_o     => c2031rom_data_o
      ); -- ieee_drive_inst

   -- and the virtual counterpart...

   vdrives_inst : entity work.vdrives
      generic map (
         VDNUM                => G_VDNUM,             -- amount of virtual drives
         BLKSZ                => 1                    -- 1 = 256 bytes block size
      )
      port map (
         clk_qnice_i          => pet_clk_sd_i,
         clk_core_i           => clk_main_i,
         reset_core_i         => not reset_core_n,

         -- MiSTer's "SD config" interface, which runs in the core's clock domain
         img_mounted_o        => iec_img_mounted,
         img_readonly_o       => iec_img_readonly,
         img_size_o           => iec_img_size,
         img_type_o           => iec_img_type,      -- 00=1541 emulated GCR(D64), 01=1541 real GCR mode (G64,D64), 10=1581 (D81)

         -- While "img_mounted_o" needs to be strobed, "drive_mounted" latches the strobe in the core's clock domain,
         -- so that it can be used for resetting (and unresetting) the drive.
         drive_mounted_o      => vdrives_mounted,

         -- Cache output signals: The dirty flags is used to enforce data consistency
         -- (for example by ignoring/delaying a reset or delaying a drive unmount/mount, etc.)
         -- and to signal via "the yellow led" to the user that the cache is not yet
         -- written to the SD card, i.e. that writing is in progress
         cache_dirty_o        => cache_dirty,
         cache_flushing_o     => open,

         -- MiSTer's "SD block level access" interface, which runs in QNICE's clock domain
         -- using dedicated signal on Mister's side such as "clk_sys"
         sd_lba_i             => reverse_vd_vec_array(iec_sd_lba),
         sd_blk_cnt_i         => reverse_vd_vec_array(iec_sd_blk_cnt),
         sd_rd_i              => iec_sd_rd,
         sd_wr_i              => iec_sd_wr,
         sd_ack_o             => iec_sd_ack,

         -- MiSTer's "SD byte level access": the MiSTer components use a combination of the drive-specific sd_ack and the sd_buff_wr
         -- to determine, which RAM buffer actually needs to be written to (using the clk_qnice_i clock domain)
         sd_buff_addr_o       => iec_sd_buf_addr,
         sd_buff_dout_o       => iec_sd_buf_data_in,
         -- Both drives inside a unit share the same track buffer, so with
         -- only 1 unit you can't see if iec_sd_buf_data_out needs to be swapped.
         sd_buff_din_i        => reverse_vd_vec_array(iec_sd_buf_data_out),
         sd_buff_wr_o         => iec_sd_buf_wr,

         -- QNICE interface (MMIO, 4k-segmented)
         -- qnice_addr is 28-bit because we have a 16-bit window selector and a 4k window: 65536*4096 = 268.435.456 = 2^28
         qnice_addr_i         => pet_qnice_addr_i,
         qnice_data_i         => pet_qnice_data_i,
         qnice_data_o         => pet_qnice_data_o,
         qnice_ce_i           => pet_qnice_ce_i,
         qnice_we_i           => pet_qnice_we_i
      ); -- vdrives_inst

    -- Use a low-pass filter to convert the 1-bit sound at 1 MHz to signed 16-bit data.
    -- Presumably this is being used at 48 kHz but it's available at 1 MHz anyway.

    lowpass_inst : entity work.lowpass
    generic map(
                N => 3,
                DIVISOR => 32
    )
    port map(
                clock => clk_main_i,
                sample_clock => ce_1m,
                sample_bit => audioDat,
                sample_out => sound_sample
    );

    audio_left_o <= sound_sample;
    audio_right_o <= sound_sample;

end architecture synthesis;

