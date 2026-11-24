# Run the RTL simulations

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

The following four testbenches retain the source text from the original Vivado project. Their filenames have been aligned with their purpose. Choose one top and add only its testbench.

| Source in the original sim_1/new folder | Repository file | Module and purpose |
| --- | --- | --- |
| dot_accelerator_tb.v | tb/dmem_accel_tb.v | dmem_accel_tb checks the MMIO dot-product low word |
| A21.v | tb/cputb.v | cputb traces the CPU and expects x10 to equal 8 for the threshold-counting program |
| cpu_tb.v | tb/historical/arithmetic_cpu_tb.v | cpu_tb checks 16 register values for an earlier arithmetic program |
| A2.1 | tb/historical/basic_memory_cpu_tb.v | cpu_tb checks five registers and two memory words for an earlier load/store program |

The current instruction ROM is initialized directly in `rtl/insmem.v`. Its loop counts the values below 20 in the initial data array. All eight entries qualify. The two historical benches expect different ROM contents, and each declares the same module name. Matching instruction images for these historical programs were not found as separate source files in the archive.

## Run the CPU branch and jump regression

Use the complete repository on disk. Run this line in the Vivado Tcl Console, substituting your repository path. The script builds only the CPU regression in a new temporary directory. It prints the path to the transcript.

```tcl
source {C:/CongMinh/github/riscv-pipeline-dot-product-accelerator/sim/run_branch_flush.tcl}
```

The CPU redirect is registered in MEM. It overrides a younger load-use stall and squashes the younger instructions in IF, ID, and EX, while the redirecting instruction can proceed to writeback. The directed program temporarily replaces the simulated ROM during reset and checks the following cases.

| Case | Observation checked by the bench |
| --- | --- |
| Taken BEQ | The wrong-path store leaves memory word 0 at 0xCAFEF00D. Registers x5 and x6 stay zero, and the target increments x10 once. |
| Untaken BNE | The fall-through instruction sets x11 to 11 and the next store writes 11 to byte address 8. |
| Taken BEQ with a younger load-use dependency | The hazard and redirect coincide. The wrong-path load and its consumer have no architectural effect, and the target increments x12 once. |
| JAL | x13 receives the link address 64. The target reads the link and writes 65 into x16. |

The success marker is `PASS cpu_branch_flush_tb`. Save the transcript from a completed run when reporting results. For the separate threshold-counting CPU example, select `cputb` from `tb/cputb.v` and use the built-in ROM without the branch testbench.

The archived synthesis report lists zero LUTs, registers, and DSPs for cpu_top, so it provides no usable area figure for the processor.
