# 🧠 8-bit Pipelined Microprocessor – IITISoC 2025

This repository contains a Verilog-based implementation of an 8-bit pipelined microprocessor, developed as part of the **IIT Indore Summer of Code (IITISoC) 2025**. The initial version was a single-cycle processor submitted for the mid evaluation. The current version is a fully functional **5-stage pipelined processor** with data and control hazard resolution.

## 📌 Overview

This project implements a custom 8-bit RISC-style processor from scratch, covering instruction fetch, decode, execution, memory access, and write-back stages. The design emphasizes clarity, modularity, and hands-on learning of computer architecture principles.

## 📂 Repository Structure

```
.
├── Compiler/
│   ├── compiler.py
│   ├── compiler_gen.py
│   ├── input_gen.txt
│   └── output_gen.txt
├── LICENSE
├── README.md
├── assembler/
│   ├── assembler.py
│   └── assembly_code
├── docs/
│   ├── Architecture_Diagram.jpg
│   └── ISA_Specification.md
├── sim/
│   ├── instruction.mem
│   └── testbench.v
└── src/
    ├── Fetch_pipeline.v
    ├── Stage_MEM.v
    ├── Stage_wb.v
    ├── alu.v
    ├── control_hazard.v
    ├── control_unit.v
    ├── data_memory.v
    ├── datapath.v
    ├── decode.v
    ├── execute.v
    ├── hazard_detection_unit.v
    ├── immediate_generator.v
    ├── raw_hazard.v
    ├── register_file.v
    ├── top_module.v
    └── write_back.v
```

## ✅ Features

### 🔹 8-bit RISC Architecture

- 8-bit wide data path  
- 3-bit register addresses (8 general-purpose registers)  
- Modular, beginner-friendly design  

### 🔹 5-Stage Pipelining

Implements a classic 5-stage instruction pipeline:

1. **IF** – Instruction Fetch  
2. **ID** – Instruction Decode  
3. **EX** – Execute  
4. **MEM** – Memory Access  
5. **WB** – Write Back  

Includes:

- Pipeline registers between stages  
- Data forwarding and hazard detection  
- Control hazard resolution with flushing  
- Basic static branch prediction  

### 🔹 Harvard Architecture

- **Instruction Memory** (ROM-like): Stores program instructions  
- **Data Memory** (RAM-like): For runtime LOAD/STORE operations  

### 🔹 Custom Instruction Set (ISA)

| Instruction | Description           | Type   |
| ----------- | --------------------- | ------ |
| ADD         | Register addition     | R-type |
| SUB         | Register subtraction  | R-type |
| AND         | Bitwise AND           | R-type |
| OR          | Bitwise OR            | R-type |
| XOR         | Bitwise XOR           | R-type |
| SLT         | Set if less than      | R-type |
| SHIFT       | Logical shift         | I-type |
| LOAD        | Load from memory      | I-type |
| STORE       | Store to memory       | I-type |
| ADDI        | Add immediate         | I-type |
| LDI         | Load immediate        | I-type |
| BEQ         | Branch if equal       | I-type |
| BNE         | Branch if not equal   | I-type |
| JMP         | Unconditional jump    | J-type |
| NOP         | No operation          | Other  |
| HLT         | Halt processor        | Other  |

### 🔹 Hazard Handling

- **Data Hazard Unit**: Stalls pipeline or forwards values when necessary  
- **Control Hazard Unit**: Flushes mispredicted instructions  
- **Forwarding Logic**: Minimizes stalls due to RAW hazards  

## 🚀 Getting Started

This guide will walk you through compiling a program, assembling it into machine code, and running the simulation.

### Prerequisites

- **Python 3**: For running the compiler and assembler scripts.
- **Icarus Verilog**: For compiling and simulating the Verilog code. You can install it using your system's package manager (e.g., `sudo apt-get install iverilog`).
- **GTKWave**: For viewing the simulation waveforms. You can install it using your system's package manager (e.g., `sudo apt-get install gtkwave`).

### Step 1: Generate Assembly Code

The `Compiler` directory contains a Python script to generate sample assembly programs.

1.  **Navigate to the project root directory.**
2.  **Run the compiler script:**
    ```sh
    python Compiler/compiler.py
    ```
3.  **Choose a program to generate.** The script will create a file named `program.txt` in the root directory containing the assembly code.

### Step 2: Assemble the Code

The `assembler` script translates the assembly code in `program.txt` into binary machine code.

1.  **Ensure you are in the project root directory.**
2.  **Run the assembler script:**
    ```sh
    python assembler/assembler.py
    ```
3.  This will generate a file named `instruction.mem` in the root directory. This file contains the 16-bit machine instructions that the processor will execute.

### Step 3: Run the Simulation

The simulation is run using Icarus Verilog from the `sim` directory.

1.  **Move the machine code file to the simulation directory:**
    ```sh
    mv instruction.mem sim/
    ```
2.  **Navigate to the simulation directory:**
    ```sh
    cd sim
    ```
3.  **Compile the Verilog source files:**
    ```sh
    iverilog -o processor.vvp testbench.v ../src/*.v
    ```
4.  **Run the compiled simulation:**
    ```sh
    vvp processor.vvp
    ```
    The simulation will start, and you will see the pipeline status printed to the console at each clock cycle.

### Step 4: View Waveforms

The simulation generates a `waveform.vcd` file, which you can view with GTKWave.

1.  **Ensure you are in the `sim` directory.**
2.  **Open the waveform file with GTKWave:**
    ```sh
    gtkwave waveform.vcd
    ```

### Running with Vivado

For users of the Xilinx Vivado Design Suite, follow these steps to run the simulation:

1.  **Create a New Project:**
    -   Launch Vivado and create a new project.
    -   Choose a project name and location.
    -   Select "RTL Project" and ensure "Do not specify sources at this time" is checked.
    -   Select a target Xilinx device (e.g., from the Artix-7 family). The specific device is not critical for simulation.

2.  **Add Design Sources:**
    -   In the "Sources" window, right-click "Design Sources" and select "Add Sources."
    -   Add all the Verilog files from the `src/` directory.

3.  **Add Simulation Sources:**
    -   Right-click "Simulation Sources" and select "Add Sources."
    -   Add the `sim/testbench.v` file.

4.  **Add Memory File:**
    -   The simulation requires the `instruction.mem` file. You will need to add this file to your project and configure the `fetch789` module to find it. In the "Sources" window, find the `instruction_memory` array declaration in `fetch789.v` under `sim_1` -> `testbench` -> `uut` -> `datapath` -> `fetch_stage`.
    -   Ensure the `$readmemb` path points to a copy of `instruction.mem` within your Vivado project directory. You may need to copy the file into your project's `sim_1/imports` directory.

5.  **Run the Simulation:**
    -   In the Flow Navigator, click "Run Simulation."
    -   The simulation will launch, and you can view the waveforms in the Vivado simulator.

## 👥 Contributors

- [Manthan Gupta](https://github.com/Manthan-cpu)  
- [Ashmita Sharma](https://github.com/ashmita2212)  
- [Aryan Jain](https://github.com/aryanj1412)  
- [Om Parekh](https://github.com/Om1903)

## 📜 License

This project is licensed under the **MIT License**. See the `LICENSE` file for more information.
