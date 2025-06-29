
# 🧠 8-bit Microprocessor – IITISoC 2025

This repository contains the Verilog-based implementation of an 8-bit microprocessor, developed as part of the IIT Indore Summer of Code (IITISoC) 2024. The current version is a single-cycle processor designed for the mid evaluation, with a pipelined version planned for the final evaluation.

## 📌 Overview

This project implements a custom 8-bit processor architecture from scratch, with basic instruction execution, modular design, and simulation testbenches. It provides hands-on understanding of processor datapaths, instruction decoding, memory interaction, and control logic.

The processor follows a RISC-style architecture, using a simple instruction set, separate instruction/data memory, and a modular Verilog HDL structure. It is designed for clarity, educational use, and future extensibility to pipelining.

## 📂 Repository Structure

```
📦IITISoc-solution 
├─ LICENSE
├─ README.md
├─ docs
│  ├─ Architecture_Diagram.jpg
│  └─ ISA_Specification
├─ sim
│  ├─ instruction.mem
│  └─ testbench.v
└─ src
   ├─ alu.v
   ├─ control_unit.v
   ├─ data_memory.v
   ├─ datapath.v
   ├─ fetchinstruction.v
   ├─ immediate_generator.v
   ├─ register_file.v
   ├─ top_module.v
   └─ write_back.v
```
## ✅ Features 

### 🔹 8-bit Architecture

All registers, memory units, and the ALU operate on 8-bit wide data, making it ideal for beginner CPU design while demonstrating all key architectural elements.

### 🔹 Single-Cycle Execution

Each instruction is fetched, decoded, executed, and written back in one clock cycle.
1. Simplifies control logic

2. Enables easy debugging

3. Tradeoff: less efficient than pipelined architectures

### 🔹 Modular Verilog Design

1. ALU: Performs arithmetic (ADD, SUB) and logic operations

2. Register File: 8-bit general-purpose registers with dual-read and single-write support

3. Control Unit: Decodes opcode, generates control signals (RegWrite, ALUSrc, MemRead, etc.)

4. Datapath: Connects all components; manages data movement

5. Instruction Memory: Stores program instructions (ROM-like)

6. Data Memory: Handles LOAD and STORE operations (RAM-like)

### 🔹 4. Custom Instruction Set (ISA)

|  Instruction  | 	Description  |  Type  |
|---|---|---|
|ADD|	Register addition|	R-type|
|SUB	|Register subtraction|	R-type|
|LOAD|	Load from data memory	|I-type|
|STORE	|Store to data memory	|I-type|
|JMP	|Unconditional jump	|J-type|
|BEQ|	Branch if equal	|B-type|

### 🔹 Separated Instruction and Data Memory

Follows Harvard architecture:
1. Instruction Memory – read-only memory with program code

2. Data Memory – used by LOAD/STORE instructions for data storage

### 🔹 Testbench and Simulation Support

A testbench.v testbench is provided for simulation:

1. Applies clock and reset

2. Loads test instructions into memory

3. Verifies correct behavior of processor

4. Compatible with tools like Icarus Verilog and GTKWave

### 🔹 Designed for Pipelining (Final Phase)

The architecture is planned to evolve into a 5-stage pipelined processor:

1. IF: Instruction Fetch

2. ID: Instruction Decode

3. EX: Execute

4. MEM: Memory Access

5. WB: Write Back

Planned additions:

1. Hazard detection and forwarding

2. Pipeline registers

3. Control and data hazard resolution

## 🚧 Planned Enhancements

✅ Convert to 5-stage pipelined processor

✅ Add branching and jump support with hazard resolution

✅ Implement new instructions (e.g., logical operations)

✅ Develop assembler or loader for custom binary programs

✅ Extend test cases and benchmarking

## 👥 Contributors

1. [Manthan Gupta](https://github.com/Manthan-cpu)
2. [Ashmita Sharma](https://github.com/ashmita2212)
3. [Aryan Jain](https://github.com/aryanj1412)
4. [Om Parekh](https://github.com/Om1903)

## 📜 License

This project is licensed under the MIT License. See the LICENSE file for more details.
