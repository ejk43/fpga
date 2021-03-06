#
# Copyright 2018 Ettus Research, A National Instruments Company
# SPDX-License-Identifier: LGPL-3.0
#


# 20 MHz White Rabbit reference
create_clock -name wr_refclk -period 50.000 [get_ports WB_20MHZ_P]

# 62.5M TXOUTCLK from the MGT that does most of the heavy lifting
create_clock -name wr_txoutclk -period 16.000 \
  [get_pins -hierarchical -filter \
    {NAME=~sfp_wrapper_0/*/cmp_xwrc_platform/gen_phy_kintex7.cmp_gtx/U_GTX_INST/gtxe2_i/TXOUTCLK}]

# 62.5M RXOUTCLK from the MGT that doesn't do as much as the TXOUTCLK
create_clock -name wr_rxoutclk -period 16.000 \
  [get_pins -hierarchical -filter \
    {NAME=~sfp_wrapper_0/*/cmp_xwrc_platform/gen_phy_kintex7.cmp_gtx/U_GTX_INST/gtxe2_i/RXOUTCLK}]

# Rename the WR 62.5M system clock
create_generated_clock -name wr_sysclk \
  [get_pins -hierarchical -filter {NAME=~sfp_wrapper_0/*/cmp_xwrc_platform/gen_default_plls.gen_kintex7_default_plls.cmp_sys_clk_pll/CLKOUT0}]

# Rename the WR ~62.5M DMTD clock
create_generated_clock -name wr_dmtdclk \
  [get_pins -hierarchical -filter {NAME=~sfp_wrapper_0/*/cmp_xwrc_platform/gen_default_plls.gen_kintex7_default_plls.cmp_dmtd_clk_pll/CLKOUT0}]



# Clock Interaction Matrix : ------------------------------------------------------------
# Everything is basically async to everything else, except for the net_clk group.
# Blanks mean there are no paths there (in the WR v4.2 build).
#
#             | wr_RXOUTCLK | wr_TXOUTCLK | wr_dmtdclk | wr_sysclk | net_clk
# wr_RXOUTCLK |    timed    |   async     |   async    |  async    |
# wr_TXOUTCLK |    async    |   timed     |   async    |  async    |
# wr_dmtdclk  |             |             |   timed    |  ???      |
# wr_sysclk   |    async    |   async     |   ???      |  timed    |  timed
# net_clk     |    async    |             |            |  timed    |  timed

set_clock_groups -asynchronous  -group [get_clocks wr_rxoutclk] \
                                -group [get_clocks wr_txoutclk] \
                                -group [get_clocks wr_dmtdclk]  \
                                -group [get_clocks net_clk]

set_clock_groups -asynchronous  -group [get_clocks wr_sysclk] \
                                -group [get_clocks wr_txoutclk] \
                                -group [get_clocks wr_rxoutclk]
