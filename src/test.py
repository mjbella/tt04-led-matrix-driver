import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

async def reset_it(dut):
    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0
    dut.strobe.value = 0
    dut.dclk.value = 0

    dut.blankt.value = 14
    await Timer(10, units='us')
    dut.strobe.value = 1
    dut.dclk.value = 1
    await Timer(10, units='us')
    dut.strobe.value = 0
    dut.dclk.value = 0
    dut.rst_n.value = 1
    await Timer(10, units='us')

async def testpattern(dut):
    dut._log.info("loadpattern")
    patternlen = 64
    pattern = [0,1,0,1,0,0,0,0,
               1,0,1,0,1,1,1,1,
               1,1,0,0,1,0,1,0,
               0,0,0,0,0,0,0,0,
               1,1,1,1,1,1,1,1,
               0,1,0,1,0,1,0,1,
               1,0,1,0,1,0,1,0,
               0,0,1,1,1,1,0,0]
               
    dut.dclk.value = 0
    dut.strobe.value = 0
    await Timer(10, units='us')
    for i,bit in enumerate(pattern):
        dut._log.info(f"Loading bit {i} of pattern")
        dut.din.value = bit
        await Timer(1, units='us')
        dut.dclk.value = 1
        await Timer(10, units='us')
        dut.dclk.value = 0
        await Timer(10, units='us')
    dut.strobe.value = 1
    await Timer(10, units='us')
    dut.strobe.value = 0
    await Timer(10, units='us')

@cocotb.test()
async def test_7seg(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    await reset_it(dut)
    await testpattern(dut)

    await ClockCycles(dut.clk, 1024*90)
