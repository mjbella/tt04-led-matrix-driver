import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

async def reset_it(dut):
    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0
    dut.strobe.value = 0
    dut.dclk.value = 0
    await Timer(10, units='us')
    dut.strobe.value = 1
    dut.dclk.value = 1
    await Timer(10, units='us')
    dut.strobe.value = 0
    dut.dclk.value = 0
    dut.rst_n.value = 1
    await Timer(10, units='us')

async def testpattern(dut):
    patternlen = 64
    pattern = [0] * patternlen
    dut.dclk.value = 0
    dut.strobe.value = 0
    await Timer(10, units='us')
    for bit in pattern:
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
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await reset_it(dut)
    await testpattern(dut)

