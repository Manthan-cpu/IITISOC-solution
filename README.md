# 🧠 8-bit Pipelined Microprocessor – IITISoC 2025

This repository contains a Verilog-based implementation of an 8-bit pipelined microprocessor, developed as part of the **IIT Indore Summer of Code (IITISoC) 2025**. The initial version was a single-cycle processor submitted for the mid evaluation. The current version is a fully functional **5-stage pipelined processor** with data and control hazard resolution.

## 📌 Overview

This project implements a custom 8-bit RISC-style processor from scratch, covering instruction fetch, decode, execution, memory access, and write-back stages. The design emphasizes clarity, modularity, and hands-on learning of computer architecture principles.

📂 Repository Structure
<pre> 📦 IITISoC-solution ├── LICENSE ├── README.md ├── docs │ ├── Architecture_Diagram.jpg │ └── ISA_Specification ├── sim │ ├── instructions.mem │ └── testbench.v └── src ├── alu.v ├── control_unit.v ├── control_hazard.v ├── data_memory.v ├── datapath_pipelined.v ├── decode.v ├── execute.v ├── fetch789.v ├── hazard_detection_unit.v ├── immediate_generator.v ├── register_file.v ├── stage_MEM.v ├── stage_WB.v ├── top_microprocessor.v └── write_back.v </pre>

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


## 👥 Contributors

- [Manthan Gupta](https://github.com/Manthan-cpu)  
- [Ashmita Sharma](https://github.com/ashmita2212)  
- [Aryan Jain](https://github.com/aryanj1412)  
- [Om Parekh](https://github.com/Om1903)

## 📜 License

This project is licensed under the **MIT License**. See the `LICENSE` file for more information.
