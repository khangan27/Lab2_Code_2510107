.data
    prompt: .asciiz "Please input a non-negative integer: "
    error_msg: .asciiz "A factorial for your number can not be found."

.text
.globl main
main:
    # Nhập số nguyên N
    li $v0, 4
    la $a0, prompt
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0       # $s0 = N

    # Kiểm tra điều kiện N>0
    bltz $s0, PrintError # Nếu N < 0 (Branch on Less Than Zero), nhảy đến báo lỗi

    # Tính N giai thừa
    li $t0, 1           # $t0 lưu kết quả giai thừa (fact = 1)
    li $t1, 1           # $t1 là biến đếm (i = 1)

Loop:
    bgt $t1, $s0, PrintResult # Nếu i > N, thoát vòng lặp đi in kết quả
    
    mul $t0, $t0, $t1   # fact = fact * i
    addi $t1, $t1, 1    # i++
    
    j Loop

    # In kết quả hợp lệ
PrintResult:
    li $v0, 1
    move $a0, $t0       # In giá trị giai thừa
    syscall
    
    j Exit              # Nhảy qua phần báo lỗi để kết thúc

    # In thông báo lỗi
PrintError:
    li $v0, 4
    la $a0, error_msg   # In câu thông báo lỗi chuẩn theo đề bài
    syscall

Exit:
    li $v0, 10          # Kết thúc chương trình
    syscall