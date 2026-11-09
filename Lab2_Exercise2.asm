.data
    prompt_a: .asciiz "a="
    prompt_b: .asciiz "b="
    str_gcd: .asciiz "GCD="
    str_lcm: .asciiz ", LCM="
    newline: .asciiz "\n"

.text
.globl main
main:
    # Nhập và kiểm tra điều kiện dương
InputA:
    li $v0, 4
    la $a0, prompt_a
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0       # $s0 = a
    blez $s0, InputA    # Nếu a <= 0, quay lại bắt nhập tiếp
    
InputB:
    li $v0, 4
    la $a0, prompt_b
    syscall
    
    li $v0, 5
    syscall
    move $s1, $v0       # $s1 = b
    blez $s1, InputB    # Nếu b <= 0, quay lại bắt nhập tiếp

    # Gọi hamd đệ quy tính GCD
    move $a0, $s0       # Truyền tham số thứ 1 = a
    move $a1, $s1       # Truyền tham số thứ 2 = b
    jal RecursiveGCD    # Nhảy đến hàm GCD (lệnh jal tự động lưu địa chỉ trả về vào $ra)
    move $s2, $v0       # Nhận kết quả trả về từ $v0 lưu vào $s2 (GCD)
    
    # Tính LCM từ GCD
    mul $t0, $s0, $s1   # $t0 = a * b
    div $t0, $s2        # Chia cho GCD
    mflo $s3            # Lấy phần nguyên lưu vào $s3 (LCM)

    # In kết quả
    li $v0, 4
    la $a0, str_gcd
    syscall
    
    li $v0, 1
    move $a0, $s2       # In GCD
    syscall
    
    li $v0, 4
    la $a0, str_lcm
    syscall
    
    li $v0, 1
    move $a0, $s3       # In LCM
    syscall
    
    # Kết thúc chương trình
    li $v0, 10
    syscall

# Hàm đệ quy tính GCD
RecursiveGCD:
    # Cất dữ liệu vào Stack để bảo toàn khi gọi đệ quy
    addi $sp, $sp, -8   # Mở rộng Stack 8 bytes (cho 2 thanh ghi)
    sw $ra, 4($sp)      # Cất địa chỉ trả về ($ra)
    sw $a1, 0($sp)      # Cất tham số b
    
    # Kiểm tra Base Case: Nếu b == 0 thì dừng đệ quy
    beq $a1, $zero, ReturnA
    
    # Chuẩn bị tham số cho bước đệ quy tiếp theo: GCD(b, a % b)
    div $a0, $a1        # Lấy a chia b
    mfhi $t0            # Lấy phần dư (a % b) cất vào $t0
    
    move $a0, $a1       # Tham số thứ 1 mới sẽ là b
    move $a1, $t0       # Tham số thứ 2 mới sẽ là phần dư (a % b)
    
    jal RecursiveGCD    # Gọi lại chính nó!
    j EndGCD            # Bỏ qua Base Case sau khi đệ quy xong

ReturnA:
    move $v0, $a0       # Nếu b == 0, gán kết quả trả về v0 = a

EndGCD:
    # Lấy lại dữ liệu từ Stack (Pop)
    lw $a1, 0($sp)      # Phục hồi tham số b
    lw $ra, 4($sp)      # Phục hồi địa chỉ trả về gốc
    addi $sp, $sp, 8    # Trả lại không gian cho Stack
    
    jr $ra              # Nhảy về địa chỉ đã gọi lệnh jal trước đó