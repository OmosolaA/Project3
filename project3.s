# N = 29
.data
	input: 	.space 80
	userInput: 	.asciiz "Enter a string with 4 characters: "
	isTooLong:	.asciiz "Input is too long."
	isEmpty:	.asciiz "Input is empty."
	invalidInput:	.asciiz "Invalid base-N number."
.text
	main: #--gets the user input
		jal get_userInput

		jal strlen   #--length is stored inreg $v0

		
		#---test if input is more than 4 character..
		li $v1,5  #---since i can't figure out how to get rid of newline "\n" i will add 1 more int...hence why 5
		slt $t1,$v1,$v0      # checks if $s0 > $s1
		beq $t1,1,isTooLong_Function 

		la $t2, userInput #--load string addr into $t2 register
        lb $t0, 0($t2)
        beq $t0, 10, isEmpty_Function #--check for an empty string
        beq $t0, 0 isEmpty_Function

				
#		j exit   #--end program		

		get_userInput:

			la $a0, userInput #--prints the string for user input 
			li $v0, 4
			syscall 

			la $a0, input #-- gets user input stores in register $A0
			li $a1, 80
			li $v0, 8
			syscall

			la $a0, input
#			syscall #--perform the operation/command
# SHOULD BE THE JUMP TO SUBPROGRAM			jal sResult


			la $a0, input

			move $a2, $a0   #--load stored user input at register $a2 back to reg $a0
			li $v0, 4       # print string
			syscall			#--execute

			strlen:
			move $t1, $zero		#--init to zero's

		loop:
			lb   $a2,0($a0)	#--address to our input
			beqz $a2,done
			addi $a0,$a0,1
			addi $t1,$t1,1
			j loop
		done:
			move $v0, $t1	#---result stored in reg $v0
			jr $ra

		stackPt1:
			addi $sp, $sp, -8 #--allocating memory for stack
		    sw $ra, 0($sp) #storing return address
		    sw $s3, 4($sp) #storing s register so it is not overwritten
		    beq $a1, $0, stackPt2 #base case
		    addi $a1, $a1, -1 #length - 1, so to start at end of string
		    add $t0, $a0, $a1 #getting address of the last byte 
		    lb $s3, 0($t0)  #loading the byte

		stackPt2:
			li $v0, 0
		    lw $ra, 0($sp)
		    lw $s3, 4($sp)
		    addi $sp, $sp, 8
		    jr $ra


		isTooLong_Function: #calls isTooLong and prints the string
			la $a0, isTooLong
			li $v0, 4
			syscall
			j exit # jump to exit

		isEmpty_Function: # calls isEmpty and prints the string
			la $a0, isEmpty
			li $v0, 4
			syscall 
			j exit # jump to exit

		invalidInput_Function:
			la $a0, invalidInput
			li $v0, 4
			syscall
			j exit

		deleteSpace:
			li $t8, 32 # space
			lb $t9, 0($a0)
			beq $t8, $t9, deleteChar
			move $t9, $a0
			j inputLength

		deleteChar:
			addi $a0, $a0, 1
			j deleteSpace

		inputLength:
			addi $t0, $t0, 0
			addi $t1, $t1, 10
			add $t4, $t4, $a0

		lengthIteration:
			lb $t2, 0($a0) # loads a sign-extended version of the byte into a 32-bit value. I.e. the most significant bit (msb) is copied into the upper 24 bits.
			beqz $t2, lengthFound
			beq $t2, $t1, lengthFound
			addi $a0, $a0, 1
			addi $t0, $t0, 1
			j lengthIteration

		lengthFound:
			beqz $t0, isEmpty_Function
			slti $t3, $t0, 5
			beqz $t3, isTooLong_Function
			move $a0, $t4
			j checkString

		checkString:
			lb $t5, 0($a0)
			beqz $t5, newConversion	
			beq $t5, $t1, newConversion
			slti $t6, $t5, 48                 # if char < ascii(48),  input invalid,   ascii(48) = 0 0 -9 restriction 
			bne $t6, $zero, invalidInput_Function
			slti $t6, $t5, 58                 # if char < ascii(58),  input is valid,  ascii(58) = 9 0 - 9 restriction 
			bne $t6, $zero, moveForward
			slti $t6, $t5, 65                 # if char < ascii(65),  input invalid,   ascii(97) = A
			bne $t6, $zero, invalidInput_Function
			slti $t6, $t5, 83                 # if char < ascii(88),  input is valid,  ascii(88) = X
			bne $t6, $zero, moveForward
			slti $t6, $t5, 97                 # if char < ascii(97),  input invalid,   ascii(97) = a
			bne $t6, $zero, invalidInput_Function
			slti $t6, $t5, 115                # if char < ascii(120), input is valid, ascii(120) = x
			bne $t6, $zero, moveForward
			bgt $t5, 116, invalidInput_Function   # if char > ascii(119), input invalid,  ascii(119) = w

		moveForward:
			addi $a0, $a0, 1
			j checkString

		newConversion:
			move $a0, $t4
			addi $t7, $t7, 0
			add $s0, $s0, $t0
			addi $s0, $s0, -1	
			li $s3, 3
			li $s2, 2
			li $s1, 1
			li $s5, 0

		baseConvert:
			lb $s4, 0($a0)
			beqz $s4, printResult
			beq $s4, $t1, printResult
			slti $t6, $s4, 58
			bne $t6, $zero, baseTen
			slti $t6, $s4, 88
			bne $t6, $zero, base29Up
			slti $t6, $s4, 120
			bne $t6, $zero, base29Low

		baseTen:
			addi $s4, $s4, -48
			j sResult

		base29Up:
			addi $s4, $s4, -55
			j sResult

		base29Low:
			addi $s4, $s4, -87

		sResult:
			beq $s0, $s3, firstChar
			beq $s0, $s2, secondChar
			beq $s0, $s1, thirdChar
			beq $s0, $s5, fourthChar

		firstChar: #--takes the number mutliplies it to convert back to base
			li $s6, 24389 #--(base 29)^3
			mult $s4, $s6
			mflo $s7
			add $t7, $t7, $s7
			addi $s0, $s0, -1
			addi $a0, $a0, 1
			j baseConvert

		secondChar:
			li $s6, 841 #--(base 29)^2
			mult $s4, $s6
			mflo $s7
			add $t7, $t7, $s7
			addi $s0, $s0, -1
			addi $a0, $a0, 1
			j baseConvert

		thirdChar:
			li $s6, 29
			mult $s4, $s6
			mflo $s7
			add $t7, $t7, $s7
			addi $s0, $s0, -1
			addi $a0, $a0, 1
			j baseConvert

		fourthChar:
			li $s6, 1
			mult $s4, $s6
			mflo $s7
			add $t7, $t7, $s7

		printResult:
			li $v0, 1
			move $a0, $t7
			li $v0, 1
			syscall

	conversionSubprogram:
		sub $t2, $t2, $t1 #move ptr back to start of string
	    addi $sp, $sp, -4 #allocating memory for stack
	    sw $ra, 0($sp) #only return address
	    move $a0, $t2
	    li $a1, 3 #string length !! 
	    li $a2, 1 #exponentiated base
	    jal stackPt1 #call to function
			
		exit:
			li $v0, 10
			syscall
