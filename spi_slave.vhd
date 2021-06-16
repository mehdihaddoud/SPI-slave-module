----------------------------------------------------------------------------------
-- POLYTECHNIQUE MONTREAL
-- ELE3311 - Systemes logiques programmables
--
-- Module Name:    spi_slave
-- Description:    Peripherique SPI
--
-- Additional Comments:
-- Le peripherique SPI ne doit supporter que les valeur CPOL / CPHA par defaut.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity spi_slave is
generic (
  SPI_CPOL              : integer := 0;
  SPI_CPHA              : integer := 0;
  DATA_WIDTH            : integer := 12
);
port (
  sclk_i                : in    std_logic;
  mosi_i                : in    std_logic;
  miso_o                : out   std_logic;
  ss_n_i                : in    std_logic;
  rx_data_o             : out   std_logic_vector(DATA_WIDTH-1 downto 0);
  rx_data_valid_o       : out   std_logic;
  tx_data_i             : in    std_logic_vector(DATA_WIDTH-1 downto 0);
  tx_data_rdy_o         : out   std_logic
);
end spi_slave;


architecture behavioral of spi_slave is

  signal sclk                 : std_logic;
  signal rx_data_p            : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rx_data_f            : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal tx_data_p            : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal tx_data_f            : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal compt_p              : integer range 0 to 12;
  signal compt_f              : integer range 0 to 12;

begin
  sclk <= sclk_i;

  REGISTERED: process(sclk, ss_n_i)
  begin
  if(ss_n_i = '1') then
    rx_data_p <= (others => '0');
    tx_data_p <= (others => '0');
    compt_p <= 0;
  elsif(rising_edge(sclk)) then
    rx_data_p <= rx_data_f;
    tx_data_p <= tx_data_f;
    compt_p <= compt_f;
  end if;
  end process;

  rx_data_f <= rx_data_p(DATA_WIDTH-2 downto 0) & mosi_i;


  miso_o <= 'Z' when ss_n_i = '1' else
            tx_data_i(DATA_WIDTH-1) when compt_p = 0 else
            tx_data_p(DATA_WIDTH-1);


  tx_data_f <= tx_data_i when compt_p = 0 else
               tx_data_p(DATA_WIDTH-2 downto 0) & '0';

  compt_f <= compt_p + 1;

  rx_data_valid_o <= '1' when compt_p = 12 else '0';
  tx_data_rdy_o <= '1' when compt_p = 0 else '0';
  rx_data_o <= rx_data_p;

end behavioral;
