.data
	charArr: .space 1000

	string1: .asciiz "Sun"
	string2: .asciiz "Mon"
	string3: .asciiz "Tue"
	string4: .asciiz "Web"
	string5: .asciiz "Thurs"
	string6: .asciiz "Fri"
	string7: .asciiz "Sat"
  
  
.text
.globl main

main:
  #li $v0, 5
 # syscall
	li $v0, 2016
  #jal LeapYear
  #la $a1, charArr
  #jal Itoa
  #la $a0, ($a1)
  #li $v0, 4
  #syscall
  #li $a0, 26
  #li $a1, 4
  #li $a2, 2019
	la $a3, charArr
  #jal Date
  #la $a0, ($v0)
	la $a0, ($a3)
  #addi $a0, $a0, 4
	jal WeekDay
  #add $a0, $v0, $zero
  #la $a0, string1
	la $a0, ($v0)
	li $v0, 4
	syscall
	j Exit

Itoa: # int Itoa(int a0, char* a1) tra ve do dai cua a1
	addi $sp, $sp, -1
	  sb $zero, 0($sp) # Them ki tu NULL vao Stack
	la $t2, ($a1) # %t2 chua dia chi cua char* a1
	add $t0, $zero, $a0 # $t0 = a0
	add $v0, $zero, $zero # vo = 0

	Itoa_Execute:
		div $t1, $t0, 10 # t1 = t0 / 10
		mfhi $t1 # du -> t1 = t0 % 10
		mflo $t0 # thuong -> t1 = t0 / 10
		addi $t1, $t1, 48 # Chuyen so sang ma ASCII tuong ung

		addi $sp, $sp, -1 # Tang 1 cho trong Stack
	  	  sb $t1, 0($sp) # Luu ki tu vao Stack

		beqz $t0, Itoa_Load_String # Neu da luu het vao Stack thi chuyen sang load vao a1
		j Itoa_Execute

	Itoa_Load_String:
		lb $t3, 0($sp) # Lay phan tu dau tien trong Stack ra luu vao $t3
	  	  sb $t3, 0($t2) # Luu $t3 vao a1[i]
	  	  addi $sp, $sp, 1 # Xoa space cua phan tu do trong Stack

		beqz $t3, Itoa_Exit # Neu gap ki tu NULL thi ngung ko lay nua

		addi $t2, $t2, 1 # $t2 <- &a1[i + 1]
		addi $v0, $v0, 1 # v0++

		j Itoa_Load_String

	Itoa_Exit:
		jr $ra # Quay tro ve ham goi ban dau

Date: # Date(int a0, int a1, int a2, char* a3)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu dia chi tra ve tren thanh ghi $ra
	addi $sp, $sp, -4
	  sw $a1, 0($sp) # Luu gia tri cua a1 vao Stack
	addi $sp, $sp, -4
	  sw $a0, 0($sp) # Luu gia tri cua a0 vao Stack
  
	la $a1, ($a3) # Luu dia chi cua a3 vao a1
	jal Itoa # Date(a0, Arr)
  
	lw $a0, 4($sp) # a0 = a1
	la $t0, ($a3) # Luu dia chi mang vao t0
	add $t1, $zero, $zero # t1 = 0

	Date_Loop_1: # Date(a1, Arr)
		beq $t1, $v0, Date_Loop_1_Exit
		addi $t0, $t0, 1 # Tang dia chi cua t0 len 1 lan
		addi $t1, $t1, 1 # t1++
		j Date_Loop_1

	Date_Loop_1_Exit:
		addi $t2, $zero, 47 # t2 = '/'
		sb $t2, 0($t0) # Luu t2 vao Mang
		addi $t0, $t0, 1 # Tang dia chi cua t0 len 1 lan
		la $a1, ($t0) # Luu dia chi cua Mang vao a1
		jal Itoa
  
		add $a0, $a2, $zero # a0 = a2
		add $t1, $zero, $zero # t1 = 0
		la $t0, ($a1) # Luu dia chi cua Mang vao t0

	Date_Loop_2: # Date(a2, Arr)
		beq $t1, $v0, Date_Loop_2_Exit
		addi $t0, $t0, 1 # Tang dia chi cua t0 len 1 lan
		addi $t1, $t1, 1 # t1++
		j Date_Loop_2

	Date_Loop_2_Exit:
		addi $t2, $zero, 47 # t2 = '/'
		sb $t2, 0($t0) # Luu t2 vao Mang
		addi $t0, $t0, 1 # Tang dia chi cua t0 len 1 lan
		la $a1, ($t0) # Luu dia chi cua Mang vao a1
		add $a0, $a2, $zero # a0 = a2
		jal Itoa
 
	Date_Exit:
		lw $a0, 0($sp) # Lay ra a0
		  addi $sp, $sp, 4
		lw $a1, 0($sp) # Lay ra a1
		  addi $sp, $sp, 4
		lw $ra, 0($sp) # Lay ra $ra
		  addi $sp, $sp, 4
		la $v0, ($a3) # return v0
		jr $ra

LeapYear: # bool LeapYear(Time a0)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu $ra vao Stack

	jal Year

	add $t0, $v0, $zero # t0 = v0, t0 la nam
	add $v0, $zero, $zero # v0 = 0
	div $t1, $t0, 400 # t0 / 400
	mfhi $t1 # t1 = t0 % 400

	beqz $t1, LeapYear_IF # If t1 = 0 then v0 = 1
	beqz $zero, LeapYear_IF_Exit

	LeapYear_IF: # Kiem tra dieu kien a0 chia het cho 400
		addi $v0, $zero, 1 # v0 = 1
		j LeapYear_Exit

	LeapYear_IF_Exit:
		div $t1, $t0, 4 # t0 / 4
		mfhi $t1 # t1 = t0 % 4
		div $t2, $t0, 100
		mfhi $t2 # t1 = t0 $ 100
		add $t1, $t1, $t2 # t1 = t1 + t2
		beq $t1, $t2, LeapYear_IF # If t1 = t1 + t2 then v0 = 1 

	LeapYear_Exit:
		lw $ra, 0($sp) # Lay gia tri cua $ra trong Stadk
		  addi $sp, $sp, 4
		jr $ra

WeekDay: # WeekDay(char* a0)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu $ra vao Stack

	jal Day
	add $t0, $v0, $zero # t0 la ngay
	jal Month
	add $t1, $v0, $zero # t1 la thang
	jal Year
	add $t2, $v0, $zero # t2 la nam
  #li $t0, 26
  #li $t1, 4
  #li $t2, 2019

		div $t3, $t2, 100 # t3 la the ky
		mfhi $t4 # t4 = t2 % 100
		bnez $t4, WeekDay_IF # If t4 !=0 then t3++
		beqz $zero, WeekDay_IF_Exit  

	WeekDay_IF:
		addi $t3, $t3, 1 # t3++

	WeekDay_IF_Exit: 
		# t0 = (ngày + tháng + n?m + n?m/4 + th? k?) mod 7
		add $t0, $t0, $t1
		add $t0, $t0, $t2
		div $t2, $t2, 4 # t2 = t2 / 4
		add $t0, $t0, $t2
		add $t0, $t0, $t3
		div $t0, $t0, 7
		mfhi $t0
  
		# Switch(t0) case:...
		bnez $t0, WeekDay_Case_1
		la $v0, string1 # k = 0 -> luu v0 = Sun
		j WeekDay_Exit

	WeekDay_Case_1:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_2
		la $v0, string2 # k = 0 -> luu v0 = Mon
		j WeekDay_Exit

	WeekDay_Case_2:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_3
		la $v0, string3 # k = 0 -> luu v0 = Tue
		j WeekDay_Exit

	WeekDay_Case_3:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_4
		la $v0, string4 # k = 0 -> luu v0 = Wed
		j WeekDay_Exit

	WeekDay_Case_4:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_5
		la $v0, string5 # k = 0 -> luu v0 = Thurs
		j WeekDay_Exit

	WeekDay_Case_5:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_6
		la $v0, string6 # k = 0 -> luu v0 = Fri
		j WeekDay_Exit

	WeekDay_Case_6:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Exit
		la $v0, string7 # k = 0 -> luu v0 = Sat
 
	WeekDay_Exit:
		lw $ra, 0($sp) # Lay gia tri cua $ra luc ban dau
 		  addi $sp, $sp, 4
		jr $ra

LeapYear_Nearest: # int* LeaYearNearest(char* a0)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu $ra vao Stack
	addi $sp, $sp, -4
	  sw $a0, 0($sp) # Luu $a0 vao Stack
	
	jal Year
	
	add $t0, $v0, $zero # t0 = v0 : year
	add $t1, $v0, $zero # t1 = v0 : year
		
	LeapYear_Nearest_Loop_1: # Tim nam nhuan nho hon 
		addi $t0, $t0, -1 # t0--
		add $a0, $t0, $zero # a0 = t0
		jal LeapYear_2	
		bnez $v0, LeapYear_Nearest_Loop_2 # if v0 = 1 then quit loop_1
		j LeapYear_Nearest_Loop_1
	
	LeapYear_Nearest_Loop_2: # Tim nam nhuan lon hon
		addi $t1, $t1, 1 # t1++
		add $a0, $t1, $zero # a0 = t1
		jal LeapYear_2	
		bnez $v0, LeapYear_Nearest_Loop_Exit # if v0 = 1 then quit loop_2
		j LeapYear_Nearest_Loop_2
	
	LeapYear_Nearest_Loop_Exit:
		add $v0, $t0, $zero # v0 chua nam nho hon
 		add $v1, $t1, $zero # v1 chua nam lon hon

	LeapYear_Nearest_Exit:
		lw $a0, 0($sp)
		  addi $sp, $sp, 4 # Tra ve gia tri ban dau cua $a0
		lw $ra, 0($sp)
		  addi $sp, $sp, 4 # Tra ve gia tri ban dau cua $ra
		jr $ra
		

LeapYear_2: # bool LeapYear(int a0)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu $ra vao Stack
	addi $sp, $sp, -4
	  sw $t0, 0($sp) # Luu $t0 vao Stack	
	addi $sp, $sp, -4
	  sw $t1, 0($sp) # Luu $t1 vao Stack

	add $t0, $a0, $zero # t0 = a0, t0 la nam
	add $v0, $zero, $zero # v0 = 0
	div $t1, $t0, 400 # t0 / 400
	mfhi $t1 # t1 = t0 % 400

	beqz $t1, LeapYear_2_IF # If t1 = 0 then v0 = 1
	beqz $zero, LeapYear_2_IF_Exit

	LeapYear_2_IF: # Kiem tra dieu kien a0 chia het cho 400
		addi $v0, $zero, 1 # v0 = 1
		j LeapYear_2_Exit

	LeapYear_2_IF_Exit:
		div $t1, $t0, 4 # t0 / 4
		mfhi $t1 # t1 = t0 % 4
		div $t2, $t0, 100
		mfhi $t2 # t1 = t0 $ 100
		add $t1, $t1, $t2 # t1 = t1 + t2
		beq $t1, $t2, LeapYear_2_IF # If t1 = t1 + t2 then v0 = 1 

	LeapYear_2_Exit:
		lw $t1, 0($sp) # Lay gia tri cua $t1 trong Stack
		  addi $sp, $sp, 4
		lw $t0, 0($sp) # Lay gia tri cua $t0 trong Stack
		  addi $sp, $sp, 4
		lw $ra, 0($sp) # Lay gia tri cua $ra trong Stack
		  addi $sp, $sp, 4
		jr $ra

 Exit:
  
 Year:

Day:

Month:
