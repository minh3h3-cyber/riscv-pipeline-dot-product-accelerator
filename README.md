# Five-Stage RISC-V Processor with a Dot-Product Accelerator

A 32-bit RISC-V processor written in Verilog with a five-stage pipeline and a memory-mapped accelerator for four-element dot products.

## Processor architecture

The processor has five stages: instruction fetch, decode, execute, memory access, and writeback. The datapath includes operand forwarding and load-use hazard detection.

- [CPU top level](rtl/cpu_top.v) connects the pipeline stages, register file, and memories.
- [Forwarding unit](rtl/forwarding_unit.v) selects operands from later pipeline stages when a register value is needed before writeback.
- [Hazard detection unit](rtl/hazard_detection_unit.v) requests a stall when an instruction depends on a preceding load.

## Dot-product accelerator

The accelerator reads two vectors of four unsigned 32-bit elements. Four parallel multipliers produce the element-wise products. A two-level adder tree combines them into a 64-bit result.

The memory-mapped interface exposes registers for the two vector base addresses, a start command, a done flag, and the low and high words of the result.

[Accelerator RTL](rtl/dot_accelerator.v) · [Memory-mapped register logic](rtl/dmem.v)

## Simulation evidence

The archived Vivado XSim testbench drives the data-memory interface directly. It writes both base addresses, starts the accelerator, and reads back the result.

| Observation | Archived result |
|---|---|
| Input vectors | A = [1, 2, 3, 4], B = [5, 6, 7, 8] |
| Expected dot product | 1×5 + 2×6 + 3×7 + 4×8 = 70 |
| Done register | 1 |
| Result register, low word | 70 |
| Testbench verdict | PASS |

[Testbench](tb/dmem_accel_tb.v) · [XSim transcript](results/dmem_accel_xsim.txt) · [How to run the simulation](sim/README.md)

## CPU verification status

A directed regression passed in Vivado XSim 2025.1 with 16 checks covering:

- Taken BEQ and suppression of wrong-path register writes and stores.
- Untaken BNE and execution of fall-through instructions.
- A taken branch coinciding with a younger load-use dependency.
- JAL target execution and the saved return address.

Simulation completed at 620 ns with `PASS cpu_branch_flush_tb`.

[Testbench](tb/cpu_branch_flush_tb.sv) · [XSim transcript](results/cpu_branch_flush_xsim.txt) · [Simulation instructions](sim/README.md)
