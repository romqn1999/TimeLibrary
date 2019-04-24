	.data
time:	.asciiz	"23/02/2019"		#declare storage for time; initial value
	.space 256
time_1:	.asciiz	"01/03/2001"		#declare storage for time; initial value
time_2:	.asciiz	"29/02/2000"		#declare storage for time; initial value

	.text
main:
	#addi $a0, $zero, 12
	#jal GetMonthName

	la $a0, time		# load address of time
	addi $a1, $zero, 'C' 	# set type for convert
	jal Convert
	
	add  $a0, $zero, $v0
	addi $v0, $zero, 4	# syscall print string
	syscall

	la $a0, time_1		# load address of time
	la $a1, time_2		# load address of time
	jal GetTime
	
	add  $a0, $zero, $v0
	addi $v0, $zero, 1
	syscall	

	addi $v0, $zero, 10	# 10 is the exit syscall
	syscall			# do the syscall
	# end main
	
	.data
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

	.text
	

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
	#Restore registers values
	lw $ra, 0($sp)
	lw $a2, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	#----------------
	endDay:
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
	add $a0, $a0, $zero
	#Restore registers values
	lw $ra, 0($sp)
	lw $a2, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	#----------------
	endMonth:
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
	#Restore registers values
	lw $ra, 0($sp)
	lw $a2, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	#----------------
	endYear:
	jr $ra


GetNum:		#GetNum(char *time, int from, int to) get number in a string from 'from' to 'to' - 1
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
	#Restore registers values
	lw $t1, 0($sp)
	lw $t0, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	#----------------
	endGetNum:
	jr $ra
	
	
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
