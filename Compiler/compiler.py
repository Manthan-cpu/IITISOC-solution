def generate_sorting_code():
   
    arr_values = [5, 8, 2]      
    n_value = len(arr_values)
    base_addr = 100             

    asm = []

    asm.append(f"LDI, R3, {n_value}")     
    asm.append("LDI, R1, 0")            
    asm.append(f"LDI, R5, {base_addr}")   

    for idx, val in enumerate(arr_values):
        asm.append(f"LDI, R6, {val}")        
        asm.append(f"STORE, R6, R5, {idx}")    
        
    asm.append("BEQ, R1, R3, 14")             
    asm.append("LDI, R2, 0")                  

    asm.append("BEQ, R2, R3, 8")             
    asm.append("LOAD, R6, R5, R1")           
    asm.append("LOAD, R7, R5, R2")           
    asm.append("SLT, R0, R7, R6, S")         
    asm.append("BEQ, R0, RZ, 2")             
    asm.append("STORE, R6, R5, R2")           
    asm.append("STORE, R7, R5, R1")
    asm.append("ADDI, R2, R2, 1, S")      
    asm.append("JMP, -8")                  

    asm.append("ADDI, R1, R1, 1, S")        
    asm.append("JMP, -14")                   

    asm.append("HLT")

    return asm


def generate_recursive_factorial(n_value=5):
    
    asm = []

    asm.append(f"LDI, R1, {n_value}")    
    asm.append("LDI, R7, 200")         
    asm.append("JMP, 3")                
    asm.append("HLT")                   
    asm.append("NOP")                 

    asm.append("LDI, R4, 15")          
    asm.append("STORE, R4, R7, 0")   
    asm.append("ADDI, R7, R7, 1, S") 
    asm.append("STORE, R1, R7, 0")     
    asm.append("ADDI, R7, R7, 1, S")  
    asm.append("LDI, R0, 1")            
    asm.append("BEQ, R1, R0, 8")        
    asm.append("ADDI, R1, R1, -1, S")  
    asm.append("JMP, -8")          
    asm.append("LDI, R2, 1")           
    asm.append("JMP, 9")              
    asm.append("ADDI, R7, R7, -1, S")  
    asm.append("LOAD, R1, R7, 0")      
    asm.append("ADDI, R7, R7, -1, S")  
    asm.append("LOAD, R4, R7, 0")       
    asm.append("LDI, R5, 0")             
    asm.append("LDI, R6, 0")            
    asm.append("BEQ, R6, R1, 4")        
    asm.append("ADD, R5, R5, R2, S")    
    asm.append("ADDI, R6, R6, 1, S")    
    asm.append("JMP, -3")              
    asm.append("LDI, R2, 0")            
    asm.append("ADD, R2, R5, R2, S")    
    asm.append("JMP, -24")              

    return asm


def save_to_file(asm_code, filename="program.txt"):
    with open(filename, "w") as f:
        for line in asm_code:
            f.write(line + "\n")
    print(f"Assembly code saved to {filename}")


if __name__ == "__main__":
    print("Select Program to Compile:")
    print("1. Sorting (Ascending)")
    print("2. Recursive Factorial")
    choice = input("Enter choice (1 or 2): ").strip()

    if choice == "1":
        asm_code = generate_sorting_code()
        save_to_file(asm_code, "program.txt")
        
    elif choice == "2":
        n_value = int(input("Enter n for factorial: "))
        asm_code = generate_recursive_factorial(n_value)
        save_to_file(asm_code, "program.txt")
    else:
        print("Invalid choice!")
