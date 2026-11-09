.data
    prompt: .asciiz "Please insert a element:\n"
    msg_val: .asciiz "Second largest value is "
    msg_idx: .asciiz ", found in index "
    comma: .asciiz ", "
    dot: .asciiz ".\n"
    
    .align 2
    arr: .space 40      # Mảng 10 phần tử x 4 bytes = 40 bytes

.text
.globl main
main:
    # --- BƯỚC 1: NHẬP MẢNG 10 PHẦN TỬ ---
    la $s0, arr         # $s0 = Base address của mảng
    li $t0, 0           # $t0 = i = 0

InputLoop:
    beq $t0, 10, FindMax1
    
    li $v0, 4
    la $a0, prompt
    syscall
    
    li $v0, 5
    syscall
    
    sll $t1, $t0, 2
    add $t1, $t1, $s0
    sw $v0, 0($t1)      # arr[i] = input
    
    addi $t0, $t0, 1
    j InputLoop

    # --- BƯỚC 2: TÌM GIÁ TRỊ LỚN NHẤT (MAX1) ---
FindMax1:
    lw $s1, 0($s0)      # Khởi tạo $s1 (Max1) = arr[0]
    li $t0, 1           # i = 1

LoopMax1:
    beq $t0, 10, FindMax2
    
    sll $t1, $t0, 2
    add $t1, $t1, $s0
    lw $t2, 0($t1)      # $t2 = arr[i]
    
    ble $t2, $s1, Skip1 # Nếu arr[i] <= Max1 thì bỏ qua
    move $s1, $t2       # Ngược lại: Max1 = arr[i]

Skip1:
    addi $t0, $t0, 1
    j LoopMax1

    # --- BƯỚC 3: TÌM GIÁ TRỊ LỚN THỨ 2 (MAX2) ---
FindMax2:
    li $s2, 0x80000000  # Khởi tạo $s2 (Max2) = Số âm nhỏ nhất (-2147483648)
    li $t0, 0           # i = 0

LoopMax2:
    beq $t0, 10, PrintResult
    
    sll $t1, $t0, 2
    add $t1, $t1, $s0
    lw $t2, 0($t1)      # $t2 = arr[i]
    
    bge $t2, $s1, Skip2 # Nếu arr[i] >= Max1 -> Bỏ qua (chỉ tìm số nhỏ hơn Max1)
    ble $t2, $s2, Skip2 # Nếu arr[i] <= Max2 -> Bỏ qua
    move $s2, $t2       # Nếu (Max2 < arr[i] < Max1) -> Cập nhật Max2 = arr[i]

Skip2:
    addi $t0, $t0, 1
    j LoopMax2

    # --- BƯỚC 4: IN KẾT QUẢ VÀ TÌM INDEX ---
PrintResult:
    # In "Second largest value is [Max2]"
    li $v0, 4
    la $a0, msg_val
    syscall
    
    li $v0, 1
    move $a0, $s2
    syscall
    
    # In ", found in index "
    li $v0, 4
    la $a0, msg_idx
    syscall
    
    li $t0, 0           # i = 0
    li $s3, 1           # Biến cờ $s3 (is_first) = 1 (Đánh dấu chưa in index nào)

LoopPrintIdx:
    beq $t0, 10, EndProgram
    
    sll $t1, $t0, 2
    add $t1, $t1, $s0
    lw $t2, 0($t1)
    
    bne $t2, $s2, SkipPrint # Nếu arr[i] != Max2 thì bỏ qua
    
    # Kiểm tra biến cờ để in dấu phẩy
    beq $s3, 1, PrintIdx    # Nếu là index đầu tiên -> Nhảy đi in index luôn
    
    # Nếu không phải index đầu tiên -> in dấu ", " trước
    li $v0, 4
    la $a0, comma
    syscall

PrintIdx:
    li $s3, 0           # Kéo cờ is_first xuống 0 (Các lần sau sẽ bị bắt đi in dấu phẩy)
    
    li $v0, 1
    move $a0, $t0       # In giá trị của index (i)
    syscall

SkipPrint:
    addi $t0, $t0, 1
    j LoopPrintIdx

EndProgram:
    # In dấu "." chốt câu
    li $v0, 4
    la $a0, dot
    syscall
    
    li $v0, 10
    syscall