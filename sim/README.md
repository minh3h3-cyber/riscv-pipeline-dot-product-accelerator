# Reproduce the MMIO dot-product test

The archived Vivado 2025.1 simulation exercises data memory and the accelerator through its memory-mapped registers. The bench drives the memory interface directly. The CPU does not issue instructions during this test.

## Vivado setup

1. Create an RTL project in a working directory outside this repository. The original project selected part `xc7z010clg225-3`.
2. Add `rtl/dmem.v` and `rtl/dot_accelerator.v` as design sources. Set the design top to `dmem`.
3. Add `tb/dmem_accel_tb.v` as a simulation source. Set the simulation top to `dmem_accel_tb`.
4. Run behavioral simulation through 160 ns. In the Tcl Console, read the lines headed `DONE REGISTER`, `RESULT LOW REGISTER` and `FINAL RESULT`. The original bench prints a verdict and calls `$finish` for either outcome.

| Test input or observation | Archived XSim run |
| --- | --- |
| Vector A at byte address 0x64 | [1, 2, 3, 4] |
| Vector B at byte address 0x74 | [5, 6, 7, 8] |
| Start command | Write 1 to 0xFFFF0008 |
| Done at 0xFFFF0014 | 1 (printed by the bench) |
| Result low at 0xFFFF000C | 70 (checked by the bench) |

The expected low word is `1×5 + 2×6 + 3×7 + 4×8 = 70`. The archived transcript is in [results/dmem_accel_xsim.txt](../results/dmem_accel_xsim.txt). Its last line retains the original source filename. The machine-specific path prefix has been removed.

Both the original bench and the data memory initialize words 25–32 at time zero. The two initial blocks can run in either order. If a new simulation produces different vectors, inspect those words before the start command. The bench also deasserts `MemRead` just before comparing `read_data`. For a portable regression, initialize the test vectors after DUT initialization and sample the result while the read enable is asserted.

## CPU test sources

All 16 RTL files and the following four testbench sources preserve the contents of the uploaded project. Testbench filenames have been aligned with their purpose. Choose one top and add only its testbench.

| Source in the original sim_1/new folder | Repository file | Module and purpose |
| --- | --- | --- |
| dot_accelerator_tb.v | tb/dmem_accel_tb.v | dmem_accel_tb checks the MMIO dot-product low word |
| A21.v | tb/cputb.v | cputb traces the CPU and expects x10 to equal 8 for the threshold-counting program |
| cpu_tb.v | tb/historical/arithmetic_cpu_tb.v | cpu_tb checks 16 register values for an earlier arithmetic program |
| A2.1 | tb/historical/basic_memory_cpu_tb.v | cpu_tb checks five registers and two memory words for an earlier load/store program |

The current instruction ROM is initialized directly in `rtl/insmem.v`. Its loop counts the values below 20 in the initial data array. All eight entries qualify. The two historical benches expect different ROM contents, and each declares the same module name. Matching instruction images for these historical programs were not found as separate source files in the archive.

The archived CPU top needs a comma after the reset port declaration in `rtl/cpu_top.v`. Its `flush` input connections on IF/ID and ID/EX have no driving assignment in that top. These issues require attention before validating the CPU from this snapshot. A CPU run needs fresh results before publishing pipeline verification claims. The archived synthesis report lists zero LUTs, registers, and DSPs for cpu_top, so it provides no usable area figure for the processor.
