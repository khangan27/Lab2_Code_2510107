.data
    prompt: .asciiz "Vui long nhap phan tu"
    colon: .asciiz ": "
    space: .asciiz " "
    .align 2            # Ép bộ nhớ canh lề 4 byte (2^2 = 4) cho biến tiếp theo
    arr: .space 20      # Mảng 5 phần tử x 4 bytes = 20 bytes

.text
.globl main
main:
    # 1. Nhập mảng 5 phần tử
    la $s0, arr         # $s0 lưu địa chỉ cơ sở của mảng
    li $t0, 0           # $t0 là biến đếm (i = 0)

InputLoop:
    beq $t0, 5, ProcessArray # Nếu i == 5, chuyển sang xử lý
    
    # In prompt
    li $v0, 4
    la $a0, prompt
    syscall
    
    li $v0, 1
    move $a0, $t0
    syscall
    
    li $v0, 4
    la $a0, colon
    syscall
    
    # Nhập số nguyên
    li $v0, 5
    syscall
    
    # Lưu vào mảng
    sll $t1, $t0, 2     # Offset = i * 4
    add $t1, $t1, $s0   # Địa chỉ phần tử hiện tại
    sw $v0, 0($t1)      # arr[i] = v0
    
    addi $t0, $t0, 1    # i++
    j InputLoop

ProcessArray:
    li $t0, 0           # Reset biến đếm i = 0

ProcessLoop:
    beq $t0, 5, PrintLoopInit # Nếu i == 5, chuyển sang in kết quả
    
    sll $t1, $t0, 2     # Offset = i * 4
    add $t1, $t1, $s0   # Địa chỉ hiện tại
    lw $t2, 0($t1)      # $t2 = arr[i]
    
    # Lấy phần dư khi chia cho 4
    andi $t3, $t2, 3    # $t3 = arr[i] % 4 (lấy 2 bit cuối)
    
    beq $t3, $zero, NextElement # Nếu dư 0 (chia hết), bỏ qua
    
    # Logic làm tròn:
    # Dư 1, 2 -> Làm tròn xuống (trừ đi phần dư)
    # Dư 3 -> Làm tròn lên (cộng thêm 1)
    li $t4, 2
    bgt $t3, $t4, RoundUp
    
RoundDown:
    sub $t2, $t2, $t3   # arr[i] = arr[i] - phần dư
    j UpdateElement

RoundUp:
    addi $t2, $t2, 1    # Dư 3 thì làm tròn lên bằng cách cộng 1

UpdateElement:
    sw $t2, 0($t1)      # Lưu lại giá trị đã làm tròn vào mảng

NextElement:
    addi $t0, $t0, 1
    j ProcessLoop

PrintLoopInit:
    li $t0, 0           # Reset biến đếm

PrintLoop:
    beq $t0, 5, Exit
    
    sll $t1, $t0, 2
    add $t1, $t1, $s0
    lw $a0, 0($t1)
    
    li $v0, 1           # In số nguyên
    syscall
    
    li $v0, 4           # In khoảng trắng
    la $a0, space
    syscall
    
    addi $t0, $t0, 1
    j PrintLoop

Exit:
    li $v0, 10          # Syscall thoát chương trình
    syscall