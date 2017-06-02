.data
    ## Variable name: open
    ## String label to begin printed representation of an array
    open:      .asciiz "["

    ## Variable name: delim
    ## String delimeter to be printed between elements of an array
    delim:     .asciiz ","

    ## Variable name: close
    ## String label to end printed representation of an array
    close:     .asciiz "]\n"
    
    ## Variable name: Array
    ## An array of integers 1 through 5
    Array:     .word 1 2 3 4 5


.text

main:
    la $a0, Array
    li $a1, 5
    jal printArray
    
    li $v0, 10
    syscall #exit


## Function:    printArray
## Definition:  void printArray(const int array[], int size)
## Parameters:  $a0 array - Array to be printed
##              $a1 size  - Number of elements in array
## Return:      N/A
## Output:      String representation of an array
## Uses data:   close, delim, open
## Registers:   Changed:   $v0, $a0, $t0
##              Preserved: $s0, $s1, $s2
## Prints a string representation of an array. A bracket is printed before and
## after the array, and a comma is between each element. For example, an array
## holding the integers 1 through 5 would display as [1,2,3,4,5].
printArray:
    addi    $sp, $sp, -16           ## push $ra and 3 saved registers to stack
    sw      $ra, 0($sp)             ## saving $ra because of syscalls
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)

    move    $s0, $a0                ## save address of array
    move    $s1, $a1                ## save size
    li      $s2, 0                  # i = 0;

    la      $a0, open
    li      $v0, 4
    syscall #print string           # printf("[");

    sgt     $t0, $s1, $zero
    beq     $t0, $zero, exitPrint   # if (size > 0)
        ptLoop:
        slt $t0, $s2, $s1
        beq $t0, $zero, exitPrint     # while (i < size)
            sll     $t0, $s2, 2         ## address offset of i
            add     $t0, $t0, $s0       ## address of array[i]
            lw      $a0, 0($t0)
            li      $v0, 1
            syscall #print integer      # printf("%d", array[i]);

            addi    $s2, $s2, 1         # i += 1;

            addi    $t0, $s2, 1         ## $t0 is if-condition
            slt     $t0, $s2, $s1
            beq     $t0, $zero, ptLoop  # if (i+1 < size)  //before last element
                la      $a0, delim
                li      $v0, 4
                syscall #print string     # printf(",");
                j    ptLoop

    exitPrint:
    la      $a0, close
    li      $v0, 4
    syscall #print string           # printf("]\n");

    lw      $ra, 0($sp)             ## pop $ra and 3 saved registers from stack
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    addi    $sp, $sp, 16
    jr      $ra                     # return;
