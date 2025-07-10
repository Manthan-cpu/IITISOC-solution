def assembler(input_file, output_file):
    opcodes = {
        'ADD': '0000', 'SUB': '0001', 'AND': '0010', 'OR': '0011',
        'XOR': '0100', 'SLT': '0101', 'SHIFT': '0110', 'LOAD': '0111',
        'STORE': '1000', 'ADDI': '1001', 'LDI': '1010', 'BEQ': '1011',
        'BNE': '1100', 'JMP': '1101', 'NOP': '1110', 'HLT': '1111'
    }
    
    def to_binary(value, bits):
        if value < 0:
            value = (1 << bits) + value
        return format(value & ((1 << bits) - 1), f'0{bits}b')
    
    def parse_register(reg):
        reg = reg.strip()
        if not reg.startswith('R') or not reg[1:].isdigit():
            raise ValueError(f"Invalid register: {reg}")
        reg_num = int(reg[1:])
        if reg_num > 7:
            raise ValueError(f"Register {reg} out of range (0-7)")
        return reg_num
    
    machine_code = []
    with open(input_file, 'r') as f:
        for line_number, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith('#'):
                continue
                

            parts = [p.strip() for p in line.split(',')]
            if not parts:
                print(f"Warning at line {line_number}: Empty instruction")
                continue
                
            opcode = parts[0].upper()
            if opcode not in opcodes:
                print(f"Error at line {line_number}: Unknown instruction '{opcode}'")
                continue
                
            binary = opcodes[opcode]
            
            try:
                if opcode in ['ADD', 'SUB', 'AND', 'OR', 'XOR', 'SLT']:
                    if len(parts) != 5:
                        raise ValueError(f"{opcode} requires format: {opcode}, Rd, Rs1, Rs2, U/S")
                    dest = parse_register(parts[1])  
                    src1 = parse_register(parts[2])  
                    src2 = parse_register(parts[3])  
                    is_unsigned = '1' if parts[4].upper() == 'U' else '0'
                    binary += to_binary(dest, 3) + to_binary(src1, 3) + to_binary(src2, 3) + is_unsigned + '00'
                
                elif opcode == 'SHIFT':
                    if len(parts) != 6:
                        raise ValueError(f"SHIFT requires format: SHIFT, Rd, Rs, Shamt, L/R, U/S")
                    dest = parse_register(parts[1])
                    src = parse_register(parts[2])
                    shamt = int(parts[3])
                    if shamt > 7:
                        raise ValueError(f"Shift amount {shamt} out of range (0-7)")
                    direction = '0' if parts[4].upper() == 'L' else '1'
                    is_unsigned = '1' if parts[5].upper() == 'U' else '0'
                    binary += to_binary(dest, 3) + to_binary(src, 3) + to_binary(shamt, 3) + direction + is_unsigned + '0'
                
                elif opcode in ['LOAD', 'STORE']:
                    if len(parts) != 4:
                        raise ValueError(f"{opcode} requires format: {opcode}, Rd/Rs, Rb, Offset")
                    reg1 = parse_register(parts[1])
                    base = parse_register(parts[2])
                    offset = int(parts[3])
                    if offset > 63 or offset < -64:
                        raise ValueError(f"Offset {offset} out of range (-64 to 63)")
                    binary += to_binary(reg1, 3) + to_binary(base, 3) + to_binary(offset, 6)
                
                elif opcode == 'ADDI':
                    if len(parts) != 5:
                        raise ValueError(f"ADDI requires format: ADDI, Rd, Rs, Imm, U/S")
                    dest = parse_register(parts[1])
                    src = parse_register(parts[2])
                    imm = int(parts[3])
                    if imm > 31 or imm < -32:
                        raise ValueError(f"Immediate {imm} out of range (-64 to 63)")
                    is_unsigned = '1' if parts[4].upper() == 'U' else '0'
                    binary += to_binary(dest, 3) + to_binary(src, 3) + to_binary(imm, 5) + is_unsigned
                
                elif opcode == 'LDI':
                    if len(parts) != 3:
                        raise ValueError(f"LDI requires format: LDI, Rd, Imm")
                    dest = parse_register(parts[1])
                    imm = int(parts[2])
                    if imm > 255 or imm < -256:
                        raise ValueError(f"Immediate {imm} out of range (-256 to 255)")
                    binary += to_binary(dest, 3) + to_binary(imm, 8) + '0'
                
                elif opcode in ['BEQ', 'BNE']:
                    if len(parts) != 4:
                        raise ValueError(f"{opcode} requires format: {opcode}, Rs1, Rs2, Offset")
                    src1 = parse_register(parts[1])
                    src2 = parse_register(parts[2])
                    offset = int(parts[3])
                    if offset > 63 or offset < -64:
                        raise ValueError(f"Offset {offset} out of range (-64 to 63)")
                    binary += to_binary(src1, 3) + to_binary(src2, 3) + to_binary(offset, 6)
                
                elif opcode == 'JMP':
                    if len(parts) != 3:
                        raise ValueError(f"JMP requires format: JMP, Addr, U/S")
                    addr = int(parts[1])
                    if addr > 255 or addr < -256:
                        raise ValueError(f"Address {addr} out of range (-256 to 255)")
                    is_unsigned = '1' if parts[2].upper() == 'U' else '0'
                    binary += to_binary(addr, 8) + is_unsigned + '000'
                
                elif opcode in ['NOP', 'HLT']:
                    if len(parts) != 1 and (len(parts) != 2 or parts[1] != ''):
                        raise ValueError(f"{opcode} requires format: {opcode}, or {opcode}")
                    binary += '0' * 12
                
                else:
                    raise ValueError(f"Unsupported instruction: {opcode}")
                
                if len(binary) != 16:
                    raise ValueError(f"Generated machine code length {len(binary)} is not 16 bits")
                
                machine_code.append(binary)
                
            except ValueError as e:
                print(f"Error at line {line_number}: {e}")
                continue
    
    with open(output_file, 'w') as f:
        for binary in machine_code:
            f.write(binary + '\n')


if __name__ == "__main__":
    input_file = "program.txt"
    output_file = "instruction.txt"
    try:
        assembler(input_file, output_file)
        print(f"Assembly complete. Machine code written to {output_file}")
    except FileNotFoundError:
        print(f"Error: Input file {input_file} not found")
    except Exception as e:
        print(f"Error: {e}")
      
