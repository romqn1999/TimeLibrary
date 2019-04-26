	.data
pause:		.space	4		#storage for pausing program

time:		.space	20		#declare storage for time
timeBackup:	.space	20		#declare storage for time backup
time1:		.space	20		#declare storage for time
time2:		.space	20		#declare storage for time

dayInput:	.asciiz "* Nhap ngay DAY: "
monthInput:	.asciiz "* Nhap thang MONTH: "
yearInput:	.asciiz "* Nhap nam YEAR: "
wrongInput:	.asciiz	"---Du lieu nhap khong hop le, nhap lai---"

time1Input:	.asciiz	"\tNhap ngay, thang, nam cho TIME_1:\n"
time2Input:	.asciiz	"\tNhap ngay, thang, nam cho TIME_2:\n"

isLeapYear:	.asciiz	" la nam nhuan"
isNotLeapYear:	.asciiz	" khong phai nam nhuan"

instruction:
	.ascii "----------Ban hay chon 1 trong cac thao tac duoi day----------\n"
	.ascii "1. Xuat chuoi TIME theo dinh dang DD/MM/YYYY\n"
	.ascii "2. Chuyen doi chuoi TIME thanh mot trong cac dinh dang sau\n"
	.ascii "\tA. MM/DD/YYYY\n"
	.ascii "\tB. Month DD, YYYY\n"
	.ascii "\tC. DD Month, YYYY\n"
	.ascii "3. Cho biet ngay vua nhap la ngay thu may trong tuan\n"
	.ascii "4. Kiem tra nam trong chuoi TIME co phai la nam nhuan khong\n"
	.ascii "5. Cho biet khoang thoi gian giua chuoi TIME_1 va TIME_2\n"
	.ascii "6. Cho biet 2 nam nhuan gan nhat voi nam trong chuoi TIME\n"
	.ascii	"<>. Thoat\n"
	.ascii "--------------------------------------------------------------\n"
	.asciiz "* Lua chon: "
types:
	.ascii "\tA. MM/DD/YYYY\n"
	.ascii "\tB. Month DD, YYYY\n"
	.ascii "\tC. DD Month, YYYY\n"
	.asciiz "\t* Lua chon: "
result:	
	.asciiz "* Ket qua: "
Msg_Convert_InvalidType:
	.asciiz "Invalid type. Type must be 'A' or 'B' or 'C'\n"
Month_String:
	.asciiz "January"	# month 1
	.asciiz "February"	# month 2
	.asciiz "March"		# month 3
	.asciiz "April"		# month 4
	.asciiz "May"		# month 5
	.asciiz "June"		# month 6
	.asciiz "July"		# month 7
	.asciiz "August"	# month 8
	.asciiz "September"	# month 9
	.asciiz "October"	# month 10
	.asciiz "November"	# month 11
	.asciiz "December"	# month 12
Space_Str:
	.asciiz " "
Comma_Str:
	.asciiz ", "
Tmp_Array:
	.space 256		# reserve space for a 256 elements array
	
string1: .asciiz "Sun"
string2: .asciiz "Mon"
string3: .asciiz "Tue"
string4: .asciiz "Wed"
string5: .asciiz "Thurs"
string6: .asciiz "Fri"
string7: .asciiz "Sat"

	.text
main:	
	#Input day, month, year loop
	inputLoop:
		la $a0, time
		jal Input	#Input date from key board
		jal IsValid	#Check if date is valid
		bne $v0, $zero, endInputLoop	#If date is valid, end iput process
		#Notify wrong input
		addi $v0, $zero, 4	#syscall print string
		la   $a0, wrongInput	#load addess string wrong input
		syscall
		jal Endline
		#------------------
		j inputLoop
	endInputLoop:
	
	#Save original time string
	la $a0, timeBackup
	la $a1, time
	jal strcpy
	#-------------------------
	
	#Menu loop
	menuLoop:
		#Get original time string
		la $a0, time
		la $a1, timeBackup
		jal strcpy	
		#------------------------
		jal Menu	
		addi $v0, $v0, -1	#start number = 0 instead of 1
		#Switch ($v0)
			bne $v0, $zero, C1	#case 1
			jal Option1
			j exitMenuCases
		C1:			#case 2
			addi $v0, $v0, -1
			bne $v0, $zero, C2
			jal Option2
			j exitMenuCases
		C2:			#case 3
			addi $v0, $v0, -1
			bne $v0, $zero, C3
			jal Option3
			j exitMenuCases
		C3:			#case 4
			addi $v0, $v0, -1
			bne $v0, $zero, C4
			jal Option4	
			j exitMenuCases
		C4:			#case 5
			addi $v0, $v0, -1
			bne $v0, $zero, C5
			jal Option5	
			j exitMenuCases
		C5:			#case 6
			addi $v0, $v0, -1
			bne $v0, $zero, C6
			jal Option6	
			j exitMenuCases
		C6:			#default
			j endMain
		#-----------------
		exitMenuCases:
			jal Pause
			j menuLoop
	#end menu loop
	
	endMain:
		addi $v0, $zero, 10	# 10 is the exit syscall
		syscall			# do the syscall
	#end main
	
Option1:
	#Save registers values
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $v0, 0($sp)
	#----------------
	addi $v0, $zero, 4
	la   $a0, result
	syscall
	
	la   $a0, time
	syscall
	jal Endline
	endOption1:
		#Restore registers values
		lw $v0, 0($sp)
		lw $a0, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		#----------------
		jr $ra
	
Option2:
	#Save registers values
	addi $sp, $sp, -16
	sw $v0, 12($sp)
	sw $a1, 8($sp)
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	#----------------
	jal Option2Menu
	
	la $a0, time		# load address of time
	add $a1, $zero, $v0 	# set type for convert
	jal Convert
	
	add $a1, $zero, $v0	# keep time's address
	addi $v0, $zero, 4	# syscall print string
	la   $a0, result
	syscall
	
	add  $a0, $zero, $a1	# time string converted
	syscall
	endOption2:
		#Restore registers values
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $v0, 12($sp)
		addi $sp, $sp, 16
		#----------------
		jr $ra
	
Option3:
	#Save registers values
	addi $sp, $sp, -16
	sw $v0, 12($sp)
	sw $t0, 8($sp)
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	#----------------
	la $a0, time
	jal WeekDay
	
	add $t0, $zero, $v0	# keep week day's address
	addi $v0, $zero, 4	# syscall print string
	la   $a0, result
	syscall
	
	add  $a0, $zero, $t0	# $a0 = week day's address
	syscall
	endOption3:
		#Restore registers values
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $t0, 8($sp)
		lw $v0, 12($sp)
		addi $sp, $sp, 16
		#----------------
		jr $ra
	
Option4:
	#Save registers values
	addi $sp, $sp, -20
	sw $v0, 0($sp)
	sw $t1, 0($sp)
	sw $t0, 0($sp)
	sw $a0, 0($sp)
	sw $ra, 0($sp)
	#----------------
	la $a0, time
	jal LeapYear
	
	add $t0, $zero, $v0	# keep isLeapYear value
	addi $v0, $zero, 4	# syscall print string
	la   $a0, result
	syscall
	
	la $a0, time
	jal Year
	add $t1, $zero, $v0	# $t1 = year
	
	addi $v0, $zero, 1	# syscall print integer
	add  $a0, $zero, $t1	# $a0 = year
	syscall
	
	beq $t0, $zero, NotLeapYear
	addi $v0, $zero, 4	# syscall print string
	la   $a0, isLeapYear
	syscall
	j endOption4
	NotLeapYear:
		addi $v0, $zero, 4	# syscall print string
		la   $a0, isNotLeapYear
		syscall
	endOption4:
		#Restore registers values
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $v0, 16($sp)
		addi $sp, $sp, 20
		#----------------
		jr $ra

Option5:
	#Save registers values
	addi $sp, $sp, -16
	sw $a1, 12($sp)
	sw $a0, 8($sp)
	sw $v0, 4($sp)
	sw $ra, 0($sp)
	#----------------
	addi $v0, $zero, 4	# syscall print string
	la   $a0, time1Input
	syscall
	la   $a0, time1
	jal Input
	
	addi $v0, $zero, 4	# syscall print string
	la   $a0, time2Input
	syscall
	la   $a0, time2
	jal Input
	
	la $a0, time1		# load address of time
	la $a1, time2		# load address of time
	jal GetTime
	
	add $a1, $zero, $v0	# keep time's address
	addi $v0, $zero, 4	# syscall print string
	la   $a0, result
	syscall
	
	add  $a0, $zero, $a1
	addi $v0, $zero, 1
	syscall
	endOption5:
		#Restore registers values
		lw $ra, 0($sp)
		lw $v0, 4($sp)
		lw $a0, 8($sp)
		lw $v1, 12($sp)
		addi $sp, $sp, 16
		#----------------
		jr $ra
	
Option6:
	#Save registers values
	addi $sp, $sp, -20
	sw $v1, 16($sp)
	sw $v0, 12($sp)
	sw $a0, 8($sp)
	sw $t0, 4($sp)
	sw $ra, 0($sp)
	#----------------
	la $a0, time
	jal LeapYear_Nearest
	
	add $t0, $zero, $v0	# keep first nearest leap year
	
	addi $v0, $zero, 4	# syscall print string
	la   $a0, result
	syscall
	
	addi $v0, $zero, 1	# syscall print integer
	add  $a0, $zero, $t0	# $a0 = first nearest leap year
	syscall
	
	addi $v0, $zero, 4	# syscall print string
	la   $a0, Comma_Str
	syscall
	
	addi $v0, $zero, 1	# syscall print integer
	add  $a0, $zero, $v1	# $a0 = second nearest leap year
	syscall
	endOption6:
		#Restore registers values
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		lw $a0, 8($sp)
		lw $v0, 12($sp)
		lw $v1, 16($sp)
		addi $sp, $sp, 20
		#----------------
		jr $ra
	
# int IsValid(char* TIME)
#	check TIME is valid date
# Register used:
#	$a0	- a pointer to null-terminated char array TIME
#	4v0	- integer 1 if valid else 0
IsValid:
				# set up the stack frame
	addi $sp, $sp, -28 	# frame size = 28
	sw   $t4, 24($sp)	# preserve $t4
	sw   $t3, 20($sp)	# preserve $t3
	sw   $t2, 16($sp)	# preserve $t2
	sw   $t1, 12($sp)	# preserve $t1
	sw   $t0, 8($sp)	# preserve $t0
	sw   $ra, 4($sp) 	# preserve the Return Address
	sw   $a0, 0($sp) 	# preserve $a0 - char* TIME
	
				# check format DD/MM/YYYY of TIME
	addi $t0, $zero, 0	# i = 0
	CheckFormat_Loop:
		add  $t1, $a0, $t0	# $t1 = (TIME + i)
		lb   $t1, 0($t1)	# $t1 = TIME[i]
		beq  $t1, $zero, CheckFormat_EndLoop	# goto CheckFormat_EndLoop if TIME[i] = '\0'
					# if ((i == 2 || i == 5) && TIME[i] != '/') then return 0
		addi $t2, $zero, 2	# $t2 = 2
		beq  $t0, $t2, Check_Delimiter_Char	# if (i == 2) goto Check_Delimiter_Char
		addi $t2, $zero, 5	# $t2 = 5
		beq  $t0, $t2, Check_Delimiter_Char	# else if (i == 5) goto Check_Delimiter_Char
		j    Check_Digit			# else goto Check_Digit
		Check_Delimiter_Char:
			addi $t2, $zero, '/'	# $t2 = '/'
			beq  $t1, $t2, CheckFormat_ContinueLoop	# if (TIME[i] = '/') then goto CheckFormat_ContinueLoop
								# else return 0
				j    IsValid_ReturnFalse
		Check_Digit:
			addi $t2, $zero, '0'	# $t2 = '0'
			slt  $t2, $t1, $t2	# $t2 = (TIME[i] < '0') ? 1 : 0
			bne  $t2, $zero, IsValid_ReturnFalse	# if (TIME[i] < '0') then goto IsValid_ReturnFalse
			addi $t2, $zero, '9'	# $t2 = '9'
			slt  $t2, $t2, $t1	# $t2 = ('9' < TIME[i]) ? 1 : 0
			bne  $t2, $zero, IsValid_ReturnFalse	# if ('9' < TIME[i]) then goto IsValid_ReturnFalse
		CheckFormat_ContinueLoop:
		addi $t0, $t0, 1	# i++
		j    CheckFormat_Loop
	CheckFormat_EndLoop:
	
				# check length of TIME is valid format
	addi $t2, $zero, 10	# $t2 = 10
	bne  $t0, $t2, IsValid_ReturnFalse	# if (i != 10) then goto IsValid_ReturnFalse
	
	jal  Day		# get day of TIME
	add  $t0, $zero, $v0	# $t0 = day
	
	jal  Month		# get month of TIME
	add  $t1, $zero, $v0	# $t1 = month
	
	jal  Year		# get year of TIME
	add  $t2, $zero, $v0	# $t1 = year
	
				# check 1 <= month <= 12
	addi $t3, $zero, 1	# $t3 = 1
	slt  $t3, $t1, $t3	# $t3 = (month < 1) ? 1 : 0
	bne  $t3, $zero, IsValid_ReturnFalse	# if (month < 1) then goto IsValid_ReturnFalse
	addi $t3, $zero, 12	# $t3 = 12
	slt  $t3, $t3, $t1	# $t3 = (12 < month) ? 1 : 0
	bne  $t3, $zero, IsValid_ReturnFalse	# if (12 < month) then goto IsValid_ReturnFalse
	
				# check 1 <= day <= DaysInMonth(month, year)
	addi $t3, $zero, 1	# $t3 = 1
	slt  $t3, $t0, $t3	# $t3 = (day < 1) ? 1 : 0
	bne  $t3, $zero, IsValid_ReturnFalse	# if (day < 1) then goto IsValid_ReturnFalse
				# get dáy in month
	add  $a0, $zero, $t1	# $a0 = month
	add  $a1, $zero, $t2	# $a1 = year
	jal  DaysInMonth	# call DaysInMonth function
	add  $t3, $zero, $v0	# $t3 = DaysInMonth(month, year)
	slt  $t3, $t3, $t0	# $t3 = (DaysInMonth(month, year) < day) ? 1 : 0
	bne  $t3, $zero, IsValid_ReturnFalse	# if (DaysInMonth(month, year) < day) then goto IsValid_ReturnFalse
	
	IsValid_ReturnTrue:
		addi $v0, $zero, 1	# $v0 = 1
		j    IsValid_Cleanup	# return
	
	IsValid_ReturnFalse:
		addi $v0, $zero, 0	# $v0 = 0
		j    IsValid_Cleanup	# return
	
	IsValid_Cleanup:
	
	lw   $a0, 0($sp) 	# restore $a0
	lw   $ra, 4($sp) 	# restore the Return Address
	lw   $t0, 8($sp)	# restore $t0
	lw   $t1, 12($sp)	# restore $t1
	lw   $t2, 16($sp)	# restore $t2
	lw   $t3, 20($sp)	# restore $t3
	lw   $t4, 24($sp)	# restore $t4
	addi $sp, $sp, 28 	# restore the Stack Pointer
	
	jr   $ra		# return
# end of IsValid function
	
Pause:		#void pause() //Stop the program temporarily
	#Save registers values
	addi $sp, $sp, -12
	sw $v0, 8($sp)	
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	#----------------
	la   $a0, pause
	addi $a1, $zero, 2
	addi $v0, $zero, 8
	syscall
	endPause:
	        #Restore registers values
		lw $a1, 0($sp)
		lw $a0, 4($sp)
		lw $v0, 8($sp)
		addi $sp, $sp, 12
		#----------------
		jr $ra

	
Input:	#void Input(char *TIME)
	#Save registers values
	addi $sp, $sp, -20
	sw $t0, 16($sp)
	sw $ra, 12($sp)
	sw $v0, 8($sp)	
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	#----------------
	add $t0, $zero, $a0
	
	addi $v0, $zero, 4
	la   $a0, dayInput
	syscall
	add $a0, $zero, $t0
	addi $a1, $zero, 3
	addi $v0, $zero, 8
	syscall
        jal Endline
        
        addi $v0, $zero, 4
	la   $a0, monthInput
	syscall
	add $a0, $zero, $t0
        addi $a0, $a0, 3
	addi $a1, $zero, 3
        addi $v0, $zero, 8
	syscall
        jal Endline
               
        addi $v0, $zero, 4
	la   $a0, yearInput
	syscall 
	add $a0, $zero, $t0
        addi $a0, $a0, 6
	addi $a1, $zero, 5
        addi $v0, $zero, 8
	syscall
        jal Endline
        
	add $a0, $zero, $t0
        addi $a1, $zero, '/'
        sb $a1, 2($a0)
        sb $a1, 5($a0)
	endInput:
	        #Restore registers values
		lw $a1, 0($sp)
		lw $a0, 4($sp)
		lw $v0, 8($sp)
		lw $ra, 12($sp)
		lw $t0, 16($sp)
		addi $sp, $sp, 20
		#----------------
		jr $ra
	

Menu:	#int Menu() return number chosen
	#Save registers values
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	#----------------
	addi $v0, $zero, 4	#syscall print string
	la   $a0, instruction
	syscall
	
	addi $v0, $zero, 5	#syscal read integer
	syscall
	endMenu:
		#Restore registers values
		lw $a0, 0($sp)
		addi $sp, $sp, 4
		#----------------
		jr $ra
	
Option2Menu:	#int Option2Menu() return type chosen
	#Save registers values
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	#----------------
	addi $v0, $zero, 4	#syscall print string
	la   $a0, types
	syscall
			
	addi $v0, $zero, 12	#syscal read character
	syscall
	jal Endline
	endOption2Menu:
		#Restore registers values
		lw $a0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		#----------------
		jr $ra

	
Endline:
	#Save registers values
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $v0, 0($sp)
	#----------------
	addi $a0, $0, 0xA
        addi $v0, $0, 0xB
        syscall
	endEndline:
		#Restore registers values
		lw $v0, 0($sp)
		lw $a0, 4($sp)
		addi $sp, $sp, 8
		#----------------
		jr $ra
	
Day:
	#Save registers values
	addi $sp, $sp, -12
	sw $a1, 8($sp)
	sw $a2, 4($sp)
	sw $ra, 0($sp)
	#----------------
	addi $a1, $zero, 0
	addi $a2, $zero, 2
	jal GetNum
	endDay:
		#Restore registers values
		lw $ra, 0($sp)
		lw $a2, 4($sp)
		lw $a1, 8($sp)
		addi $sp, $sp, 12
		#----------------
		jr $ra

Month:
	#Save registers values
	addi $sp, $sp, -12
	sw $a1, 8($sp)
	sw $a2, 4($sp)
	sw $ra, 0($sp)
	#----------------
	addi $a1, $zero, 3
	addi $a2, $zero, 5
	jal GetNum
	endMonth:
		#Restore registers values
		lw $ra, 0($sp)
		lw $a2, 4($sp)
		lw $a1, 8($sp)
		addi $sp, $sp, 12
		#----------------
		jr $ra

Year:
	#Save registers values
	addi $sp, $sp, -12
	sw $a1, 8($sp)
	sw $a2, 4($sp)
	sw $ra, 0($sp)
	#----------------
	addi $a1, $zero, 6
	addi $a2, $zero, 10
	jal GetNum
	endYear:
		#Restore registers values
		lw $ra, 0($sp)
		lw $a2, 4($sp)
		lw $a1, 8($sp)
		addi $sp, $sp, 12
		#----------------
		jr $ra


GetNum:		#GetNum(char *TIME, int from, int to) get number in a string from 'from' to 'to' - 1
	#Save registers values
	addi $sp, $sp, -12
	sw $a1, 8($sp)
	sw $t0, 4($sp)
	sw $t1, 0($sp)
	#----------------
	addi $v0, $zero, 0
	
	loopGetNum:
		slt $t0, $a1, $a2	#t0 = (a1 < a2) ? 1 : 0
		beq  $t0, $zero, endLoopGetNum	#if (t0 == 0) endLoop
		add  $t0, $a0, $a1	#t0 = current digit's address
		lb   $t1, 0($t0)	#t1 = current digit in ascii
		subi $t1, $t1, '0'	#t1 = current digit
		#v0 = v0 * 10
		sll  $t0, $v0, 3
		sll  $v0, $v0, 1
		add  $v0, $v0, $t0
		#-----------------
		add  $v0, $v0, $t1	#v0 += t1
		addi $a1, $a1, 1
		j loopGetNum
	endLoopGetNum:
	
	endGetNum:
	#Restore registers values
		lw $t1, 0($sp)
		lw $t0, 4($sp)
		lw $a1, 8($sp)
		addi $sp, $sp, 12
		#----------------
		jr $ra
	
# char* Convert(char* TIME, char type)
#	convert format of char array TIME from "DD/MM/YYYY" to 'type'
# Register used:
# 	$a0   	- pointer of char array TIME in format "DD/MM/YYYY"
#	$a1   	- the type
#			type 'A': "MM/DD/YYYY"
#			type 'B': "Month DD, YYYY"
#			type 'C': "DD Month, YYYY"
#	$v0   	- return pointer of char array TIME
Convert:
	addi $sp, $sp, -32 	# assign size of stack in use
	sw   $t4, 28($sp)	# preserve $t4
	sw   $t3, 24($sp)	# preserve $t3
	sw   $t2, 20($sp)	# preserve $t2
	sw   $t1, 16($sp)	# preserve $t1
	sw   $t0, 12($sp)	# preserve $t0
	sw   $ra, 8($sp) 		# preserve the Return Address
	sw   $a1, 4($sp) 		# preserve $a1 - char type
	sw   $a0, 0($sp) 		# preserve $a0 - char* TIME

	addi $t0, $zero, 'A'	# type 'A'
	beq  $a1, $t0, Convert_A	# if type == 'A' then Convert_A
	addi $t0, $zero, 'B'	# type 'B'
	beq  $a1, $t0, Convert_B	# else if type == 'B' then Convert_B
	addi $t0, $zero, 'C'	# type 'C'
	beq  $a1, $t0, Convert_C	# else if type == 'C' then Convert_C
	j    Convert_InvalidType	# else goto Convert_InvalidType
	
	Convert_A:
		# DD/MM/YYYY -> MM/DD/YYYY
		# get day
		lb   $t0, 0($a0)	# $t0 = TIME[0]
		lb   $t1, 1($a0)	# $t1 = TIME[1]
		# get month
		lb   $t3, 3($a0)	# $t3 = TIME[3]
		lb   $t4, 4($a0)	# $t4 = TIME[4]
		# swap day and month
		sb   $t3, 0($a0)	# TIME[0] = $t3
		sb   $t4, 1($a0)	# TIME[1] = $t4
		sb   $t0, 3($a0)	# TIME[3] = $t0
		sb   $t1, 4($a0)	# TIME[4] = $t1
		# convert done
		j    Convert_Clear

	Convert_B:
		# DD/MM/YYYY -> Month DD, YYYY
		
		jal  Day		# get day in time
		add  $t0, $zero, $v0	# $t0 = day
		
		jal  Month		# get month in time
		add  $t1, $zero, $v0	# $t1 = month
		
		jal  Year		# get year int time
		add  $t2, $zero, $v0	# $t2 = year
		
		add  $a0, $zero, $t1	# $a0 = month (integer, parameter for GetMonthName function)
		jal  GetMonthName	# get month name of month
					# copy month name to TIME
		lw   $a0, 0($sp)	# set base address of TIME to $a0
		add  $a1, $zero, $v0	# $a1 = $v0 pointer of month name
		jal  strcpy
					# concatenate " "
		la   $a1, Space_Str	# $a1 = base address of Space_Str
		jal  strcat
					# convert integer day to string
		add  $a0, $zero, $t0	# $a0 = day
		la   $a1, Tmp_Array	# $a1 = base address of Tmp_Array, array use to store string converted
		jal  itoa
					# concatenate string day
		lw   $a0, 0($sp)	# $a0 = base address of TIME
		add  $a1, $zero, $v0	# $a1 = base address of string day
		jal  strcat
					# concatenate ", "
		la   $a1, Comma_Str	# $a1 = base address of Comma_Str
		jal  strcat
					# convert integer year to string
		add  $a0, $zero, $t2	# $a0 = year
		la   $a1, Tmp_Array	# $a1 = base address of Tmp_Array, array use to store string converted
		jal  itoa
					# concatenate string year
		lw   $a0, 0($sp)	# $a0 = base address of TIME
		add  $a1, $zero, $v0	# $a1 = base address of string year
		jal  strcat
		# convert done
		j    Convert_Clear

	Convert_C:
		# DD/MM/YYYY -> DD Month, YYYY
		
		jal  Day		# get day in time
		add  $t0, $zero, $v0	# $t0 = day
		
		jal  Month		# get month in time
		add  $t1, $zero, $v0	# $t1 = month
		
		jal  Year		# get year int time
		add  $t2, $zero, $v0	# $t2 = year
		
					# convert integer day to string
		add  $a0, $zero, $t0	# $a0 = day
		la   $a1, Tmp_Array	# $a1 = base address of Tmp_Array, array use to store string converted
		jal  itoa
					# concatenate string day
		lw   $a0, 0($sp)	# $a0 = base address of TIME
		add  $a1, $zero, $v0	# $a1 = base address of string day
		jal  strcpy
					# concatenate " "
		la   $a1, Space_Str	# $a1 = base address of Space_Str
		jal  strcat
					# get month name of month
		add  $a0, $zero, $t1	# $a0 = month (integer, parameter for GetMonthName function)
		jal  GetMonthName
					# copy month name to TIME
		lw   $a0, 0($sp)	# $a0 = base address of TIME
		add  $a1, $zero, $v0	# $a1 = $v0 pointer of month name
		jal  strcat
					# concatenate ", "
		la   $a1, Comma_Str	# $a1 = base address of Comma_Str
		jal  strcat
					# convert integer year to string
		add  $a0, $zero, $t2	# $a0 = year
		la   $a1, Tmp_Array	# $a1 = base address of Tmp_Array, array use to store string converted
		jal  itoa
					# concatenate string year
		lw   $a0, 0($sp)	# $a0 = base address of TIME
		add  $a1, $zero, $v0	# $a1 = base address of string year
		jal  strcat
		# convert done
		j    Convert_Clear

	Convert_InvalidType:
		la   $a0, Msg_Convert_InvalidType
		addi $v0, $zero, 4	# syscall print string
		syscall

	Convert_Clear:
		add  $v0, $zero, $a0	# return pointer of char array TIME
		lw   $a0, 0($sp) 	# restore $a0
		lw   $a1, 4($sp) 	# restore $a1
		lw   $ra, 8($sp) 	# restore the Return Address
		lw   $t0, 12($sp)	# restore $t0
		lw   $t1, 16($sp)	# restore $t1
		lw   $t2, 20($sp)	# restore $t2
		lw   $t3, 24($sp)	# restore $t3
		lw   $t4, 28($sp)	# restore $t4
		addi $sp, $sp, 32 	# restore the Stack Pointer
	
	jr   $ra			# return
# end of Convert function


# char* GetMonthName(int month)
# 	get month name of month (1 <= month <= 12)
# Register used:
# 	$a0   	- integer 'month' in range [1; 12]
#	$v0   	- return pointer of char array month name
GetMonthName:
				# set up the stack frame:
	addi $sp, $sp, -20	# frame size = 20
	sw   $t2, 16($sp)	# preserve $t2
	sw   $t1, 12($sp)	# preserve $t1
	sw   $t0, 8($sp)	# preserve $t0
	sw   $ra, 4($sp)	# preserve the return address
	sw   $a0, 0($sp)	# preserve $a0

	la   $t0, Month_String	# load address of month string. $t0 will be the pointer to month name
	add  $t1, $zero, $t0	# $t1 = $t0; i = $t1
	LoopMonthString:
		# if (Month_String[i] == '\0' && $a0 == 1)
		#	$t0 = i + 1, month = month - 1;
		lb $t2, 0($t1)	# $t2 = Month_String[i]
		bne $t2, $zero, IncIteratorMonthString
				# goto IncIteratorMonthString if Month_String[i] != '\0'
			addi $a0, $a0, -1	# month = month - 1
		addi $t2, $zero, 1
		bne $a0, $t2, IncIteratorMonthString
				# goto IncIteratorMonthString if $a0 != 1
			addi $t0, $t1, 1	# $t0 = i + 1. $t0 is a pointer to month name
		IncIteratorMonthString:
			addi $t1, $t1, 1	# i = i + 1
		bne $a0, $zero, LoopMonthString	# goto LoopMonthString if month != 0

	#add $a0, $zero, $t0
	#addi $v0, $zero, 4
	#syscall

	add $v0, $zero, $t0	# return pointer of char array month name

	lw   $a0, 0($sp)	# restore $a0
	lw   $ra, 4($sp)	# restore the return address
	lw   $t0, 8($sp)	# restore $t0
	lw   $t1, 12($sp)	# restore $t1
	lw   $t2, 16($sp)	# restore $t2
	addi $sp, $sp, 20	# restore stack pointer
	
	jr $ra			# return
# end of GetMonthName function
	
	
# char* strcat(char* destination, const char* source)
#	append a copy of the 'source' string to the 'destination' string
# Register used:
#	$a0	- pointer to the destination array, which should contain a string, and be large enough to contain the concatenated resulting string
#	$a1	- string to be appended. This should not overlap 'destination'
#	$v0	- a pointer to the resulting null-terminated string, same as parameter 'destination'
strcat:
				# set up the stack frame:
	addi $sp, $sp, -20	# frame size = 20
	sw   $t1, 16($sp)	# preserve $t1
	sw   $t0, 12($sp)	# preserve $t0
	sw   $ra, 8($sp)	# preserve the return address
	sw   $a0, 4($sp)	# preserve $a0
	sw   $a1, 0($sp)	# preserve $a1
	
	addi $t0, $zero, 0	# i = 0
	FindNull_Loop:
		add  $t1, $t0, $a0	# $t1 = (destination + i)
		lb   $t1, 0($t1)	# $t1 = destination[i]
		beq  $t1, $zero, FindNull_EndLoop	# goto GetLength_EndLoop if destination[i] == '\0'
		addi $t0, $t0, 1	# i++
		j    FindNull_Loop
	FindNull_EndLoop:
	
	add  $a0, $t0, $a0	# $a0 = (destination + i) where destination[i] == '\0'
	jal  strcpy
	
	lw   $a1, 0($sp)	# restore $a1
	lw   $a0, 4($sp)	# restore $a0
	lw   $ra, 8($sp)	# restore the return address
	lw   $t0, 12($sp)	# restore $t0
	lw   $t1, 16($sp)	# restore $t1
	addi $sp, $sp, 20	# restore the stack pointer
	
	add  $v0, $zero, $a0	# 'destination' is returned
	
	jr   $ra		# return
# end of strcat function


# char* strcpy(char* destination, const char* source)
#	copies string pointed by 'source' into the array pointed by 'destination', including the terminating null character (and stopping at that point)
#Register used:
#	$a0	- pointer to the destination array where the content is to be copied
#	$a1	- pointer to the source to be copied
#	$v0	- 'destination' is returned
strcpy:
				# set up the stack frame:
	addi $sp, $sp, -28	# frame size = 28
	sw   $t3, 24($sp)	# preserve $t3
	sw   $t2, 20($sp)	# preserve $t2
	sw   $t1, 16($sp)	# preserve $t1
	sw   $t0, 12($sp)	# preserve $t0
	sw   $ra, 8($sp)	# preserve the return address
	sw   $a1, 4($sp)	# preserve $a1
	sw   $a0, 0($sp)	# preserve $a0
	
	add  $t0, $zero, $zero	# i = 0
	strcpy_Loop:
					# set destiantion[i] = source[i]
		add  $t1, $t0, $a1	# $t1 = (source + i)
		lb   $t2, 0($t1)	# $t2 = *(source + i)
		add  $t3, $t0, $a0	# $t3 = (destination + i)
		sb   $t2, 0($t3)	# destination[i] = source[i]
		beq  $t2, $zero, strcpy_EndLoop	# goto strcp_EndLoop if source[i] = '\0'
		addi $t0, $t0, 1
		j strcpy_Loop
	strcpy_EndLoop:
	
	lw   $a0, 0($sp)	# restore $a0
	lw   $a1, 4($sp)	# restore $a1
	lw   $ra, 8($sp)	# restore the return address
	lw   $t0, 12($sp)	# restore $t0
	lw   $t1, 16($sp)	# restore $t1
	lw   $t2, 20($sp)	# restore $t2
	lw   $t3, 24($sp)	# restore $t3
	addi $sp, $sp, 28	# restore stack pointer
	
	add  $v0, $zero, $a0	# return 'destination'
	
	jr $ra
#end of strcpy function


# char* itoa(int value, char* str)
#	convert integer in base 10 to string
#Register used:
#	$a0	- value to be converted to a string
#	$a1	- array in memory where to store the resulting null-terminated string
#	$v0	- a pointer to the resulting null-terminated string, same as parameter str
itoa:
				# set up the stack frame:
	addi $sp, $sp, -32	# frame size = 32
	sw   $t4, 28($sp)	# preserve $t4
	sw   $t3, 24($sp)	# preserve $t3
	sw   $t2, 20($sp)	# preserve $t2
	sw   $t1, 16($sp)	# preserve $t1
	sw   $t0, 12($sp)	# preserve $t0
	sw   $ra, 8($sp)	# preserve the return address
	sw   $a1, 4($sp)	# preserve $a1
	sw   $a0, 0($sp)	# preserve $a0
	
	add  $t0, $zero, $zero	# i = 0
	
	bne  $a0, $zero, Value_NotEqual_Zero	# if value != 0 then goto Value_NotEqual_Zero
					# if value == 0
		add  $t1, $t0, $a1	# $t1 = (str + i)
		addi $t2, $zero, '0'	# $t2 = '0'
		sb   $t2, 0($t1)	# str[i] = '0'
		addi $t0, $t0, 1	# i = i + 1
		#add  $t1, $t0, $a1	# $t1 = (str + i)
		#addi $t2, $zero, 0	# $t2 = '\0'
		#sb   $t2, 0($t1)	# str[i] = '\0'
		j    itoa_Return	# goto return
	Value_NotEqual_Zero:
	
	slt  $t1, $a0, $zero	# $t1 = (value < 0) ? 1 : 0
	beq  $t1, $zero, Value_Not_Negative	# if value >= 0 then goto Value_Not_Negative
					# if value < 0
		addi $t2, $zero, -1	# $t2 = -1
		mult $a0, $t2		# multiplication: set hi to high-order 32 bits, lo to low-order 32 bits of the product of $a0 and $t2
		mflo $a0		# value = value * (-1)
	Value_Not_Negative:
	
	itoa_Loop:
		beq  $a0, $zero, itoa_EndLoop	# goto itoa_EndLoop if value == 0
		addi $t2, $zero, 10
		div  $a0, $t2		# divide $a0 by 10 then set LO to quotient and HI to remainder
		mfhi $t2		# $t2 = value % 10
		add  $t3, $t0, $a1	# $t3 = (str + i)
		addi $t4, $t2, '0'	# $t4 = $t2 + '0'
		sb   $t4, 0($t3)	# str[i] = $t4
		addi $t0, $t0, 1	# i = i + 1
		mflo $a0		# value = value / 10;
		j itoa_Loop
	itoa_EndLoop:
	
	beq  $t1, $zero, itoa_Return	# goto itoa_Return if value is not negative
					# if value < 0, append '-'
		add  $t3, $t0, $a1	# $t3 = (str + i)
		addi $t4, $zero, '-'	# $t4 = '-'
		sb   $t4, 0($t3)	# str[i] = $t4
		addi $t0, $t0, 1	# i = i + 1
		
	itoa_Return:
					# append string terminator
		add  $t3, $t0, $a1	# $t3 = (str + i)
		addi $t4, $zero, 0	# $t4 = '\0'
		sb   $t4, 0($t3)	# str[i] = $t4
					# reserve the string
		add  $a0, $zero, $a1	# $a0 = $a1, parameter for reserve string function
		add  $a1, $zero, $t0	# $a1 = length, parameter for reserve string function
		jal  ReserveStr
	
	lw   $a0, 0($sp)	# restore $a0
	lw   $a1, 4($sp)	# restore $a1
	lw   $ra, 8($sp)	# restore the return address
	lw   $t0, 12($sp)	# restore $t0
	lw   $t1, 16($sp)	# restore $t1
	lw   $t2, 20($sp)	# restore $t2
	lw   $t3, 24($sp)	# restore $t3
	lw   $t4, 28($sp)	# restore $t4
	addi $sp, $sp, 32	# restore stack pointer
	
	add  $v0, $zero, $a1	# $v0 = $a1
	
	jr   $ra		# return
#end of itoa function


# void ReserveStr(char* str, int length)
#	reserve the string 'str' of length 'length'
#Register used:
#	$a0	- pointer to the string to be reserved
#	$a1	- length of string
ReserveStr:
				# set up the stack frame:
	addi $sp, $sp, -36	# frame size = 36
	sw   $t5, 32($sp)	# preserve $t5
	sw   $t4, 28($sp)	# preserve $t4
	sw   $t3, 24($sp)	# preserve $t3
	sw   $t2, 20($sp)	# preserve $t2
	sw   $t1, 16($sp)	# preserve $t1
	sw   $t0, 12($sp)	# preserve $t0
	sw   $ra, 8($sp)	# preserve the return address
	sw   $a1, 4($sp)	# preserve $a1
	sw   $a0, 0($sp)	# preserve $a0
	
	addi $t0, $zero, 0	# $t0 = 0 is the start of string
	addi $t1, $a1, -1	# $t1 = length - 1 is the end of string
	Reserve_Loop:
		slt  $t2, $t0, $t1	# $t2 = (start < end) ? 1 : 0
		beq  $t2, $zero, Reserve_EndLoop	# goto Reserve_EndLoop if start >= end
					#swap str[start], str[end]
		add  $t2, $t0, $a0	# $t2 = (str + start)
		add  $t3, $t1, $a0	# $t3 = (str + end)
		lb   $t4, 0($t2)	# $t4 = str[start]
		lb   $t5, 0($t3)	# $t5 = str[end]
		sb   $t5, 0($t2)	# str[start] = str[end]
		sb   $t4, 0($t3)	# str[end] = str[start]
		addi $t0, $t0, 1	# start++
		addi $t1, $t1, -1	# end--
		j    Reserve_Loop
	Reserve_EndLoop:
	
	lw   $a0, 0($sp)	# restore $a0
	lw   $a1, 4($sp)	# restore $a1
	lw   $ra, 8($sp)	# restore the return address
	lw   $t0, 12($sp)	# restore $t0
	lw   $t1, 16($sp)	# restore $t1
	lw   $t2, 20($sp)	# restore $t2
	lw   $t3, 24($sp)	# restore $t3
	lw   $t4, 28($sp)	# restore $t4
	lw   $t5, 32($sp)	# restore $t5
	addi $sp, $sp, 36	# restore stack pointer
		
	jr   $ra	# return
#end of ReserveStr function

# int GetTime(char* TIME_1, char* TIME_2)
#	Get time gap in years between TIME_1 and TIME_2
# Register used:
#	$a0	- pointer to TIME_1
#	$a1	- pointer to TIME_2
#	$v0	- integer time gap in years between TIME_1 and TIME_2
GetTime:
				# set up the stack frame:
	addi $sp, $sp, -40	# frame size = 40
	sw   $t6, 36($sp)	# preserve $t6
	sw   $t5, 32($sp)	# preserve $t5
	sw   $t4, 28($sp)	# preserve $t4
	sw   $t3, 24($sp)	# preserve $t3
	sw   $t2, 20($sp)	# preserve $t2
	sw   $t1, 16($sp)	# preserve $t1
	sw   $t0, 12($sp)	# preserve $t0
	sw   $ra, 8($sp)	# preserve the return address
	sw   $a1, 4($sp)	# preserve $a1
	sw   $a0, 0($sp)	# preserve $a0
	
	jal  Day		# get day of TIME_1
	add  $t0, $zero, $v0	# $t0 = day_1
	jal  Month		# get month of TIME_1
	add  $t1, $zero, $v0	# $t1 = month_1
	jal  Year		# get year of TIME_1
	add  $t2, $zero, $v0	# $t2 = year_1
	
	add  $a0, $zero, $a1	# $a0 = $a1 is pointer to TIME_2
	jal  Day		# get day of TIME_2
	add  $t3, $zero, $v0	# $t3 = day_2
	jal  Month		# get month of TIME_2
	add  $t4, $zero, $v0	# $t4 = month_2
	jal  Year		# get year of TIME_2
	add  $t5, $zero, $v0	# $t5 = year_2
	
	slt  $t6, $t0, $t3	# $t6 = (day_1 < day_2) ? 1 : 0
	beq  $t6, $zero, Greater_Day	# if (day_1 >= day_2) then goto Greater_Day
					# if (day_1 < day_2)
		addi $t1, $t1, -1	# month_1--
		bne  $t1, $zero, Valid_Month	# if (month_1 != 0) then goto Valid_Month
						# if (month_1 == 0)
			addi $t1, $zero, 12	# month_1 = 12
			addi $t2, $t2, -1	# year_1--
		Valid_Month:
					# calculate days in month for month_1
		add  $a0, $zero, $t1	# $a0 = month_1
		add  $a1, $zero, $t2	# $a1 = year_1
		jal  DaysInMonth
		add  $t0, $t0, $v0	# day_1 += DaysInMonth of month_1
	Greater_Day:
	
	slt  $t6, $t1, $t4	# $t6 = (month_1 < month_2) ? 1 : 0
	beq  $t6, $zero, Greater_Month	# if (month_1 >= month_2) then goto Greater_Month
					# if (month_1 < month_2)
		addi $t2, $t2, -1	# year_1--
		addi $t1, $t1, 12	# month_1 += 12
	Greater_Month:
	
	sub  $t0, $t0, $t3	# $t0 = day_1 - day_2 is diff_day
	sub  $t1, $t1, $t4	# $t1 = month_1 - month_2 is diff_month
	sub  $t2, $t2, $t5	# $t2 = year_1 - year_2 is diff_year
	
	slt  $t6, $t2, $zero	# $t6 = (diff_year < 0) ? 1 : 0
	beq  $t6, $zero, Greater_Year	# if (diff_year > 0) then goto Greater_Year
					# if (diff_year < 0)
		addi $t6, $zero, -1	# $t6 = -1
		mult $t2, $t6		# multiplication: set hi to high-order 32 bits, lo to low-order 32 bits of the product of $t2 and $t6
		mflo $t2		# diff_year = diff_year * (-1)
		add  $t6, $t0, $t1	# $t6 = day_1 + month_1
		beq  $t6, $zero, Greater_Year	# if (day_1 + month_1 == 0) then goto Greater_Year
						# if (day_1 + month_1 != 0)
			addi $t2, $t2, -1	# diff_year--
	Greater_Year:
	
	add  $v0, $zero, $t2	# return diff_year
	
	lw   $a0, 0($sp)	# restore $a0
	lw   $a1, 4($sp)	# restore $a1
	lw   $ra, 8($sp)	# restore the return address
	lw   $t0, 12($sp)	# restore $t0
	lw   $t1, 16($sp)	# restore $t1
	lw   $t2, 20($sp)	# restore $t2
	lw   $t3, 24($sp)	# restore $t3
	lw   $t4, 28($sp)	# restore $t4
	lw   $t5, 32($sp)	# restore $t5
	lw   $t6, 36($sp)	# restore $t6
	addi $sp, $sp, 40	# restore stack pointer
	
	jr $ra
# end of GetTime function
	
	
# int DaysInMonth(int month, int year)
#	calculate number of days in a month
# Register used:
#	$a0	- the month
#	$a1	- the year
#	$v0	- integer number of days
DaysInMonth:
	.data
daysInMonth:
	.word 31	# month 1
	.word 28	# month 2
	.word 31	# month 3
	.word 30	# month 4
	.word 31	# month 5
	.word 30	# month 6
	.word 31	# month 7
	.word 31	# month 8
	.word 30	# month 9
	.word 31	# month 10
	.word 30	# month 11
	.word 31	# month 12
	.text
				# set up the stack frame:
	addi $sp, $sp, -16	# frame size = 40
	sw   $t0, 12($sp)	# preserve $t0
	sw   $ra, 8($sp)	# preserve the return address
	sw   $a1, 4($sp)	# preserve $a1
	sw   $a0, 0($sp)	# preserve $a0
	
	la   $v0, daysInMonth	# load base address of daysInMonth array
	sll  $t0, $a0, 2	# $t0 = $a0 * (2^2)
	add  $v0, $v0, $t0	# $v0 = (daysInMonth + month)
	lw   $v0, -4($v0)	# $v0 = daysInMonth[month - 1] just because array start from 0
	
	addi $t0, $zero, 2	# $t0 = 2
	bne  $a0, $t0, DaysInMonth_CleanUp	# if (month != 2) then goto DaysInMonth_CleanUp
					# if (month == 2)
					# check leap year. isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
					# check for (year % 4 == 0 && year % 100 != 0)
		addi $t0, $zero, 4	# $t0 = 4
		div  $a1, $t0		# divide year by 4 then set LO to quotient and HI to remainder
		mfhi $t0		# $t0 = year % 4
		bne  $t0, $zero, CmpMonthMod400	# if (year % 4 != 0) then goto CmpMonthMod400
		addi $t0, $zero, 100	# $t0 = 100
		div  $a1, $t0		# divide year by 100 then set LO to quotient and HI to remainder
		mfhi $t0		# $t0 = year % 100
		beq  $t0, $zero, CmpMonthMod400	# if (year % 100 == 0) then goto CmpMonthMod400
			j    IsLeapYear		# if (year % 4 == 0 && year % 100 != 0) then goto IsLeapYear
		CmpMonthMod400:		# check for (year % 400 == 0)
		addi $t0, $zero, 400	# $t0 = 400
		div  $a1, $t0		# divide year by 400 then set LO to quotient and HI to remainder
		mfhi $t0		# $t0 = year % 400
		bne  $t0, $zero, DaysInMonth_CleanUp	# if (year % 400 != 0) then goto DaysInMonth_CleanUp
			IsLeapYear:		# this is leap year
			addi $v0, $v0, 1	# days in month 2 = 29
	
	DaysInMonth_CleanUp:
	lw   $a0, 0($sp)	# restore $a0
	lw   $a1, 4($sp)	# restore $a1
	lw   $ra, 8($sp)	# restore the return address
	lw   $t0, 12($sp)	# restore $t0
	addi $sp, $sp, 16	# restore stack pointer
	
	jr $ra
# end of DaysInMonth function

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
#End of Itoa function

Date: # Date(int a0, int a1, int a2, char* a3)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu dia chi tra ve tren thanh ghi $ra
	addi $sp, $sp, -4
	  sw $a1, 0($sp) # Luu gia tri cua a1 vao Stack
	addi $sp, $sp, -4
	  sw $a0, 0($sp) # Luu gia tri cua a0 vao Stack
	addi $sp, $sp, -4
	  sw $t0, 0($sp) # Luu gia tri cua t0 vao Stack
	addi $sp, $sp, -4
	  sw $t1, 0($sp) # Luu gia tri cua t1 vao Stack
	addi $sp, $sp, -4
	  sw $t2, 0($sp) # Luu gia tri cua t2 vao Stack
  
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
		lw $t2, 0($sp) # Lay ra t2
		  addi $sp, $sp, 4
		lw $t1, 0($sp) # Lay ra t1
		  addi $sp, $sp, 4
		lw $t0, 0($sp) # Lay ra t0
		  addi $sp, $sp, 4
		lw $a0, 0($sp) # Lay ra a0
		  addi $sp, $sp, 4
		lw $a1, 0($sp) # Lay ra a1
		  addi $sp, $sp, 4
		lw $ra, 0($sp) # Lay ra $ra
		  addi $sp, $sp, 4
		la $v0, ($a3) # return v0
		jr $ra
#End of Date function

LeapYear: # bool LeapYear(Time a0)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu $ra vao Stack
	addi $sp, $sp, -4
	  sw $t0, 0($sp) # Luu $t0 vao Stack
	addi $sp, $sp, -4
	  sw $t1, 0($sp) # Luu $t1 vao Stack
	addi $sp, $sp, -4
	  sw $t2, 0($sp) # Luu $t2 vao Stack

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
		lw $t2, 0($sp) # Lay gia tri cua $t2 trong Stadk
		  addi $sp, $sp, 4
		lw $t1, 0($sp) # Lay gia tri cua $t1 trong Stadk
		  addi $sp, $sp, 4
		lw $t0, 0($sp) # Lay gia tri cua $t0 trong Stadk
		  addi $sp, $sp, 4
		lw $ra, 0($sp) # Lay gia tri cua $ra trong Stadk
		  addi $sp, $sp, 4
		jr $ra
#End of LeapYear function

WeekDay: # WeekDay(char* a0)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu $ra vao Stack
	addi $sp, $sp, -4
	  sw $t0, 0($sp) # Luu $t0 vao Stack
	addi $sp, $sp, -4
	  sw $t1, 0($sp) # Luu $t1 vao Stack
	addi $sp, $sp, -4
	  sw $t2, 0($sp) # Luu $t2 vao Stack
	addi $sp, $sp, -4
	  sw $t3, 0($sp) # Luu $t3 vao Stack
	addi $sp, $sp, -4
	  sw $t4, 0($sp) # Luu $t4 vao Stack

	jal Day
	add $t0, $v0, $zero          # t0 la ngay
	jal Month
	add $t1, $v0, $zero 	     # t1 la thang
	jal Year
	add $t2, $v0, $zero 	     # t2 la nam
	div $t3, $t2, 100            # t3 = t2 / 100 : la the ky
	mfhi $t2                     

	addi $t4, $zero, 3           # t4 = 3
	slt $t4, $t1, $t4	     
	bnez $t4, WeekDay_IF         # If t1 < 3 then t1 += 12
	beqz $zero, WeekDay_IF_Exit  

	WeekDay_IF:
		addi $t1, $t1, 12 # t1 += 12

	WeekDay_IF_Exit: 
		# t0 = (ngày + tháng + n?m + n?m/4 + th? k?) mod 7
		addi $t1, $t1, 1              # t1 = 13/5*(t1+1)
		addi $v0, $zero, 13
		mult $t1, $v0
		mflo $t1
		div $t1, $t1, 5
		add $t0, $t0, $t1             # t0 = t0 + t1

		add $t0, $t0, $t2             # t0 = t0 + t2
		div $t2, $t2, 4               # t2 = t2 / 4
		add $t0, $t0, $t2             # t0 = t0 + t2/4
		
		addi $v0, $zero, 2
		mult $t3, $v0                 # t2 = 2*t3
		mflo $t2
		sub $t0, $t0, $t2	      # t0 = t0 - t2
		div $t3, $t3, 4               # t3 = t3 / 4
		add $t0, $t0, $t3             # t0 = t0 + t3

		div $t0, $t0, 7
		mfhi $t0
  
		# Switch(t0) case:...
		bnez $t0, WeekDay_Case_1
		la $v0, string7               # k = 0 -> luu v0 = Sat
		j WeekDay_Exit

	WeekDay_Case_1:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_2
		la $v0, string1               # k = 1 -> luu v0 = Sun
		j WeekDay_Exit

	WeekDay_Case_2:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_3
		la $v0, string2               # k = 2 -> luu v0 = Mon
		j WeekDay_Exit

	WeekDay_Case_3:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_4
		la $v0, string3               # k = 3 -> luu v0 = Tue
		j WeekDay_Exit

	WeekDay_Case_4:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_5
		la $v0, string4               # k = 4 -> luu v0 = Wed
		j WeekDay_Exit

	WeekDay_Case_5:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Case_6
		la $v0, string5               # k = 5 -> luu v0 = Thurs
		j WeekDay_Exit

	WeekDay_Case_6:
		addi $t0, $t0, -1
		bnez $t0, WeekDay_Exit
		la $v0, string6               # k = 6 -> luu v0 = Fri
 
	WeekDay_Exit:
		lw $t4, 0($sp) # Lay gia tri cua $ra luc ban dau
 		  addi $sp, $sp, 4
		lw $t3, 0($sp) # Lay gia tri cua $ra luc ban dau
 		  addi $sp, $sp, 4
		lw $t2, 0($sp) # Lay gia tri cua $ra luc ban dau
 		  addi $sp, $sp, 4
		lw $t1, 0($sp) # Lay gia tri cua $ra luc ban dau
 		  addi $sp, $sp, 4
		lw $t0, 0($sp) # Lay gia tri cua $ra luc ban dau
 		  addi $sp, $sp, 4
		lw $ra, 0($sp) # Lay gia tri cua $ra luc ban dau
 		  addi $sp, $sp, 4
		jr $ra
#End of WeekDay function

LeapYear_Nearest: # int* LeaYearNearest(char* time)
	addi $sp, $sp, -4
	  sw $ra, 0($sp) # Luu $ra vao Stack
	addi $sp, $sp, -4
	  sw $a0, 0($sp) # Luu $a0 vao Stack
	addi $sp, $sp, -4
	  sw $t0, 0($sp) # Luu $t0 vao Stack
	addi $sp, $sp, -4
	  sw $t1, 0($sp) # Luu $t1 vao Stack
	
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
		lw $t1, 0($sp)
		  addi $sp, $sp, 4 # Tra ve gia tri ban dau cua $t1
		lw $t0, 0($sp)
		  addi $sp, $sp, 4 # Tra ve gia tri ban dau cua $t0
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
