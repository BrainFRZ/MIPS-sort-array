## Name:     Terry Weiss (466751950)
## Date:     March 25, 2017
## Email:    ttweiss@syr.edu
## Course:   CIS 341 M001
## Project:  Project 1

.data
    ## Variable name: Array
    ## Unsorted array
    Array:     .word   1 4 7 10 25 3 5 13 17 21

    ## Variable name: C
    ## Temporary array to build sorted array within merge routine
    C:         .space  400  # 100 words

    ## Variable name: open
    ## String label to begin printed representation of an array
    open:      .asciiz "["

    ## Variable name: delim
    ## String delimeter to be printed between elements of an array
    delim:     .asciiz ","

    ## Variable name: close
    ## String label to end printed representation of an array
    close:     .asciiz "]\n"

    ## Variable name: unsorted
    ## String label to be printed before an unsorted array
    unsorted:  .asciiz "Unsorted: "

    ## Variable name: sorted
    ## String label to be printed before a sorted array
    sorted:    .asciiz "Sorted:   "


.text
## Function:    main
## Definition:  void main()
## Parameters:  N/A
## Return:      N/A
## Output:      Array sorted and unsorted (see printArray)
## Uses data:   Array, sorted, unsorted
## Registers:   Changed: $v0, $a0, $a1, $a2, $a3
## Implements a merge sort following the provided C++ source code logic.
main:
    la      $a0, unsorted
    li      $v0, 4
    syscall #print string           # printf("Unsorted: ");

    la   $a0, Array
    li   $a1, 10
    jal  printArray                 # printArray(Array, 10);

    la  $a0, Array
    li  $a1, 0
    li  $a2, 9
    add $a3, $a1, $a2
    sra $a3, $a3, 1                 # mid = (low + high) / 2
    jal merge                       # merge(Array, min, max, mid)

    la      $a0, sorted
    li      $v0, 4
    syscall #print string           # printf("Sorted:   ");

    la  $a0, Array
    li  $a1, 10
    jal printArray                  # printArray(Array, 10);

    li      $v0, 10
    syscall #exit                   # exit(0);

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

    blez    $s1, exitPrint          # if (size > 0)
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


## Function:    merge
## Definition:  void merge(int a[], int low, int high, int mid)
## Return:      N/A
## Parameters   $a0 a     - Array to be sorted (destroyed)
##              $a1 low   - First index in range to be sorted
##              $a2 high  - Last index in range to be sorted
##              $a3 mid   - Middle index in range to be sorted
## Output:      N/A
## Uses data:   C
## Registers:   Changed:   $t0, $t1, $t2, $t3, $t4, $t5, $t6
## Implements a merge sort helper function following the provided C++ source
## code logic. This function uses the global `C` array to build the sorted
## version of the original array passed by `a`, and then overwrites the
## original array. As a result, `a` can't have a length longer than 100.
merge:
    la   $t0, C                     ## $t0 is base address of C
    move $t1, $a1                   # int i = low;
    move $t3, $a1                   # int k = low;
    addi $t2, $a3, 1                # int j = mid + 1;

    whileMerge: ## break array into mergable blocks
    sle  $t4, $t1, $a3              ## i <= mid
    sle  $t5, $t2, $a2              ## j <= high
    and  $t4, $t4, $t5
    beq  $t4, $zero, whileBottom    # while (i <= mid && j <= high)
        sll $t4, $t1, 2               ## index offset of i
        add $t4, $a0, $t4             ## address of a[i]
        lw  $t5, 0($t4)               ## $t5 is a[i]
        sll $t4, $t2, 2               ## index offset of j
        add $t4, $a0, $t4             ## address of a[j]
        lw  $t6, 0($t4)               ## $t6 is a[j]
        slt $t4, $t5, $t6
        beq $t4, $zero, elseGTE       # if (a[i] < a[j])
            sll  $t4, $t3, 2            ## index offset of k
            add  $t4, $t0, $t4          ## address of c[k]
            sw   $t5, 0($t4)            # c[k] = a[i];
            addi $t3, $t3, 1            # k++;
            addi $t1, $t1, 1            # i++;
            j    whileMerge           ## skip else block
        elseGTE:                      # else
            sll  $t4, $t3, 2            ## index offset of k
            add  $t4, $t0, $t4          ## address of c[k]
            sw   $t6, 0($t4)            # c[k] = a[j];
            addi $t3, $t3, 1            # k++;
            addi $t2, $t2, 1            # j++;
            j    whileMerge           ## end if-check and while

    whileBottom: ## build bottom half of sorted array
    sle  $t4, $t1, $a3
    beq  $t4, $zero, whileTop       # while (i <= mid)
        sll  $t4, $t1, 2              ## index offset of i
        add  $t4, $a0, $t4            ## address of a[i]
        lw   $t5, 0($t4)              ## $t5 is a[i]
        sll  $t4, $t3, 2              ## index offset of k
        add  $t4, $t0, $t4            ## address of c[k]
        sw   $t5, 0($t4)              # c[k] = a[i];
        addi $t3, $t3, 1              # k++;
        addi $t1, $t1, 1              # i++;
        j    whileBottom              ## end while

    whileTop: ## build top half of sorted array
    sle  $t4, $t2, $a2
    beq  $t4, $zero, forCopyInit    # while (j <= high)
        sll  $t4, $t2, 2              ## index offset of j
        add  $t4, $a0, $t4            ## address of a[j]
        lw   $t5, 0($t4)              ## $t5 is a[j]
        sll  $t4, $t3, 2              ## index offset of k
        add  $t4, $t0, $t4            ## address of c[k]
        sw   $t5, 0($t4)              # c[k] = a[i];
        addi $t3, $t3, 1              # k++;
        addi $t2, $t2, 1              # j++;
        j    whileBottom              ## end while

    forCopyInit: ## copy temporary sorted array over passed array
    move $t1, $a1                   ## for-init
    forCopy:
    slt  $t4, $t1, $t3              ## for-test
    beq  $t4, $zero, mergeExit      # for (i = low; i < k; i++)
        sll  $t6, $t1, 2              ## index offset of i
        add  $t4, $t0, $t6            ## address for c[i]
        lw   $t5, 0($t4)              ## $t5 is c[i]
        add  $t4, $a0, $t6            ## address for a[i]
        sw   $t5, 0($t4)              # a[i] = c[i];
        addi $t1, $t1, 1              ## for-step
        j    forCopy                  ## end for

    mergeExit:
    jr   $ra                        # return;
