def compiler(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    variables = {}
    register_counter = 1
    assembly_code = []
    labels = {}
    pending_labels = []

    def get_register(var):
        nonlocal register_counter
        if var not in variables:
            if register_counter > 8:
                raise ValueError("Out of registers (max 8)")
            variables[var] = f"R{register_counter}"
            register_counter += 1
        return variables[var]

    def parse_expression(lhs, rhs):
        # Handle operators with precedence
        if '<<' in rhs:
            var, shamt = rhs.split('<<')
            src = get_register(var.strip())
            dest = get_register(lhs)
            assembly_code.append(f"SHIFT {dest}, {src}, {int(shamt)}, L, S")

        elif '>>' in rhs:
            var, shamt = rhs.split('>>')
            src = get_register(var.strip())
            dest = get_register(lhs)
            assembly_code.append(f"SHIFT {dest}, {src}, {int(shamt)}, R, S")

        elif '+' in rhs:
            left, right = [x.strip() for x in rhs.split('+')]
            dest = get_register(lhs)
            if right.isdigit():
                src = get_register(left)
                assembly_code.append(f"ADDI {dest}, {src}, {right}, S")
            else:
                src1, src2 = get_register(left), get_register(right)
                assembly_code.append(f"ADD {src1}, {src2}, {dest}, S")

        elif '-' in rhs:
            left, right = [x.strip() for x in rhs.split('-')]
            src1, src2 = get_register(left), get_register(right)
            dest = get_register(lhs)
            assembly_code.append(f"SUB {src1}, {src2}, {dest}, S")

        elif '&' in rhs:
            src1, src2 = [get_register(x.strip()) for x in rhs.split('&')]
            dest = get_register(lhs)
            assembly_code.append(f"AND {src1}, {src2}, {dest}")

        elif '|' in rhs:
            src1, src2 = [get_register(x.strip()) for x in rhs.split('|')]
            dest = get_register(lhs)
            assembly_code.append(f"OR {src1}, {src2}, {dest}")

        elif '^' in rhs:
            src1, src2 = [get_register(x.strip()) for x in rhs.split('^')]
            dest = get_register(lhs)
            assembly_code.append(f"XOR {src1}, {src2}, {dest}")

        elif '<' in rhs:
            src1, src2 = [get_register(x.strip()) for x in rhs.split('<')]
            dest = get_register(lhs)
            assembly_code.append(f"SLT {src1}, {src2}, {dest}, S")

        elif rhs.isdigit():
            dest = get_register(lhs)
            assembly_code.append(f"LDI {dest}, {rhs}")

        else:
            src = get_register(rhs)
            dest = get_register(lhs)
            assembly_code.append(f"ADDI {dest}, {src}, 0, S")

    for lineno, line in enumerate(lines, 1):
        line = line.strip().strip(';')
        if not line or line.startswith("//"):
            continue

        try:
            if line.startswith("int "):
                line = line.replace("int ", "")

            if '=' in line and not line.startswith("if") and "mem[" not in line:
                lhs, rhs = [x.strip() for x in line.split('=')]
                parse_expression(lhs, rhs)

            elif line.startswith("if"):
                condition = line[line.index('(')+1:line.index(')')].strip()
                label = f"L{len(labels)}"
                if '==' in condition:
                    src1, src2 = [get_register(x.strip()) for x in condition.split('==')]
                    assembly_code.append(f"BNE {src1}, {src2}, {label}")
                elif '!=' in condition:
                    src1, src2 = [get_register(x.strip()) for x in condition.split('!=')]
                    assembly_code.append(f"BEQ {src1}, {src2}, {label}")
                pending_labels.append(label)

            elif line.startswith("goto"):
                label = line.split()[1]
                assembly_code.append(f"JMP {label}")

            elif line.lower() == "nop":
                assembly_code.append("NOP")

            elif line.lower() == "hlt":
                assembly_code.append("HLT")

            elif 'mem[' in line and ']=' in line:
                left, right = line.split('=')
                addr_expr = left[left.index('[')+1:left.index(']')].strip()
                src = get_register(right.strip())
                if '+' in addr_expr:
                    base, offset = [x.strip() for x in addr_expr.split('+')]
                    base_reg = get_register(base)
                    assembly_code.append(f"STORE {src}, {base_reg}, {offset}")
                else:
                    base_reg = get_register(addr_expr)
                    assembly_code.append(f"STORE {src}, {base_reg}, 0")

            elif '=' in line and 'mem[' in line:
                lhs, mem_expr = [x.strip() for x in line.split('=')]
                addr_expr = mem_expr[mem_expr.index('[')+1:mem_expr.index(']')].strip()
                dest = get_register(lhs)
                if '+' in addr_expr:
                    base, offset = [x.strip() for x in addr_expr.split('+')]
                    base_reg = get_register(base)
                    assembly_code.append(f"LOAD {dest}, {base_reg}, {offset}")
                else:
                    base_reg = get_register(addr_expr)
                    assembly_code.append(f"LOAD {dest}, {base_reg}, 0")

            elif pending_labels:
                # Assign label to current instruction
                label = pending_labels.pop(0)
                labels[label] = len(assembly_code)

        except Exception as e:
            print(f"Error on line {lineno}: {e}")

    # Patch labels
    final_code = []
    for instr in assembly_code:
        parts = instr.split()
        if parts[-1] in labels:
            offset = labels[parts[-1]] - (len(final_code) + 1)
            instr = ' '.join(parts[:-1] + [str(offset)])
        final_code.append(instr)

    with open(output_file, 'w') as f:
        for instr in final_code:
            f.write(instr + '\n')

    print(f"Compilation complete. Assembly written to {output_file}")


if __name__ == "__main__":
    compiler("high_level_test.txt", "program.txt")
