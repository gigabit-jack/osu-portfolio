TITLE String pimitives and you: a study in useful tediousness.        (Proj5_gobenj.asm)

; Author:                   Josh Goben
; Last Modified:            06/11/2023
; OSU email address:        gobenj@oregonstate.edu
; Course number/section:    CS 271 Section 400
; Project Number: 06        Due Date: 06/11/2023
; Description: This program will do the following:
;   Instruct users to enter in a number of integers - 10 by default - and then 
;   print the integers, their sum, and their average. The programs uses string
;   primitives and macros to read in the value as a string, convert it to an 
;   integer, then convers the integers back to strings for the final print.

INCLUDE Irvine32.inc

INPUT_MAX           = 11
ARRAYSIZE           = 10
NL                  TEXTEQU <13,10>         ; CrLf constant
ASCIICOMMA          = 2Ch
ASCIISPACE          = 20h


.data

input_msg_1         BYTE    "Please enter an integer value: ",0
input               BYTE    INPUT_MAX DUP(?)
input_integer       SDWORD  0
input_count         DWORD   ?    
invalid_input       BYTE    "That is not a valid signed integer, try again.",NL,0
overflow_msg        BYTE    NL,"WHAT ARE YOU TRYING TO DO?!?! That number is too large for a 32-bit register.",NL,
                            "Stop overcompensating and try again with something more reasonable.",NL,NL,0
integer_array       SDWORD  INPUT_MAX DUP(?)
output_string       BYTE    INPUT_MAX DUP(?)
string_buffer       BYTE    INPUT_MAX DUP(?)
array_sum           DWORD   0
array_avg           DWORD   ?
program_title       BYTE    "String primitives and you: a study in useful tediousness.",NL,0
program_author      BYTE    "by: Josh Goben <gobenj@oregonstate.edu>",NL,NL,0
instruct_1          BYTE    "Greetings! In this program, you will enter 10 signed integer values.",NL,0
instruct_2          BYTE    "Each number must fit within a 32-bit register, keeping in mind that it is a signed integer.",NL,0
instruct_3          BYTE    "Once we have 10 integers, this program will report the following",NL,0
instruct_4          BYTE    "1. All the integers",NL,"2. The sum of the integers",NL,"3. The average value.",NL,NL,0
report_1            BYTE    NL,NL,"Great job! You entered the following numbers: ",NL,0
report_2            BYTE    NL,NL,"The sum of all these numbers is: ",0
report_3            BYTE    NL,"And the truncated average of these numbers is: ",0
report_space        BYTE    ASCIISPACE,0
farewell_msg_1      BYTE    NL,NL,"Thanks for providing these numbers, run the program again for more excitement!",NL,0
farewell_msg_2      BYTE    "Chevron 7 - Locked!",NL,0


.code

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user and then gets a string of characters and stores in a BYTE array.
;
; Preconditions: INPUT_MAX is defined as a constant of max string characters
;
; Postconditions: changes registers eax, ecx, edx and restores from stack
;
; Receives:
;   [param]msg          = input message string offset
;   [param]input_dest   = input string destination
;   [param]count        = data label to store count of characters entered
;
; Returns: 
;   input_dest  = BYTE array of string that was entered
;   count       = number of characters entered, stored in 32bit register
; ---------------------------------------------------------------------------------
mGetString MACRO msg:REQ, input_dest:REQ, count:REQ
    push    ECX
    push    EDX
    push    EAX

    mDisplayString msg

    mov     ECX, INPUT_MAX + 1
    mov     EDX, input_dest
    call    ReadString
    mov     count, EAX

    pop     EAX
    pop     EDX
    pop     ECX

ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Receives an offset for a string array and prints using the WriteString called
;   prodecure from the Irvine32 library.
;
; Preconditions: string array has been passed as a parameter
;
; Postconditions: changes register edx and restores from stack
;
; Receives:
;   [param]display_string = offset of string array to be printed
;
; Returns: prints string to console
; ---------------------------------------------------------------------------------
mDisplayString MACRO display_string:REQ
    push    EDX

    mov     EDX, display_string
    call    WriteString

    pop     EDX

ENDM


main PROC
; --------------------------------
; Prints intro and instructions 
; --------------------------------
    push    OFFSET instruct_4               ; 28 = instruct_4
    push    OFFSET instruct_3               ; 24 = instruct_3
    push    OFFSET instruct_2               ; 20 = instruct_2
    push    OFFSET instruct_1               ; 16 = instruct_1
    push    OFFSET program_author           ; 12 = program_author
    push    OFFSET program_title            ;  8 = program_title
    call    introduction

; --------------------------------
; Gets values using the ReadVal procedure, then stores them in an array.
; --------------------------------    
    mov     ECX, ARRAYSIZE
    mov     EDI, OFFSET integer_array
    sub     EDI, TYPE integer_array
_getValuesLoop:
    push    OFFSET overflow_msg             ; 28 = overflow message for 33+ bits
    push    OFFSET invalid_input            ; 24 = invalid input string message
    push    OFFSET input_integer            ; 20 = integer storage data label
    push    OFFSET input_msg_1              ; 16 = input message
    push    OFFSET input                    ; 12 = string input holder
    push    input_count                     ;  8 = input count holder
    call    ReadVal

    ; move value to array 
    add     EDI, TYPE integer_array
    mov     EAX, input_integer
    mov     [EDI], EAX
    mov     input_integer, 0
    loop    _getValuesLoop

; --------------------------------
; Generates sum of all values in the array and then stores in variable.
; --------------------------------
    mov     EAX, 4294967295  
    xor     EAX, EAX                        ; set EAX to zero

    mov     ECX, ARRAYSIZE                  ; ECX = number of values in array
    mov     ESI, OFFSET integer_array

    ; loop through array and add each value to EAX
_fillSum:    
    add     EAX, [ESI]
    add     ESI, TYPE integer_array
    loop    _fillSum
    mov     array_sum, EAX                  ; EAX = sum of array

; --------------------------------
; Generate average and store in variable. Uses ARRAYSIZE as the implied number 
;   of elements.
; --------------------------------
    mov     EAX, 4294967295  
    xor     EAX, EAX                        ; set EAX to zero

    mov     EAX, array_sum
    mov     EBX, ARRAYSIZE 
    cdq
    idiv    EBX
    mov     array_avg, EAX                  ; store quotient, drop remainder

; --------------------------------
; Print all array values in order of entry and uses a single space between 
;   each value. Uses the mDisplayString macro to print the string and WriteVal
;   procedure to print the integer.
; -------------------------------- 
    mov     ECX, ARRAYSIZE                  ; ECX = number of values in array
    mov     ESI, OFFSET integer_array
    push    EDX
    mDisplayString OFFSET report_1
    pop     EDX

    ; loop through array and print each value
_printArrayValues:
    push    ECX
    push    ESI
    push    OFFSET output_string            ; 16 = output string placeholder
    push    OFFSET string_buffer            ; 12 = buffer to hold reversed string
    push    [ESI]                           ;  8 = input integer
    call    WriteVal
    push    EDX
    mDisplayString OFFSET report_space
    pop     EDX
    pop     ESI
    pop     ECX
    add     ESI, TYPE integer_array
    loop    _printArrayValues

; --------------------------------
; Prints the sum of all entered value using the mDisplayString for strings and 
;   WriteVal for the integer.
; --------------------------------
    push    EDX
    mDisplayString OFFSET report_2
    pop     EDX
    push    OFFSET output_string            ; 16 = output string placeholder
    push    OFFSET string_buffer            ; 12 = buffer to hold reversed string
    push    array_sum                       ;  8 = sum value as integer
    call    WriteVal

; --------------------------------
; Prints the average of all entered value using the mDisplayString for strings 
;   and WriteVal for the integer.
; --------------------------------
    push    EDX
    mDisplayString OFFSET report_3
    pop     EDX
    push    OFFSET output_string            ; 16 = output string placeholder
    push    OFFSET string_buffer            ; 12 = buffer to hold reversed string
    push    array_avg                       ;  8 = sum value as integer
    call    WriteVal

; --------------------------------
; Say goodbye 
; --------------------------------
    push    OFFSET farewell_msg_2           ; 12  = farewell_msg_2
    push    OFFSET farewell_msg_1           ;  8   = farewell_msg_1
    call    farewell
    
    Invoke ExitProcess,0	                ; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Prompts the user for an integer and reads in a string that the user privides.
;   It then validates that the string is a valid integer that will fit within a
;   32-bit register. If validation is successful, it converts the provided
;   string to an actual integer by using string primitives.
;
; Preconditions: ARRAYSIZE is stored as a constant
;   The input string buffer, input count data label, and integer data label are 
;   all initialized and passed via OFFSET addressing.
;
; Postconditions: changes registers al, eax, ebx, ecx, edi, esi and restores from stack
;   input_integer = holds the value after conversion to integer
;   input = the string that the user entered before conversion
;
; Receives:
;   [ebp + 28] = overflow message for 33+ bits
;   [ebp + 24] = invalid input string message
;   [ebp + 20] = integer storage data label
;   [ebp + 16] = input instruction message
;   [ebp + 12] = string input holder
;   [ebp +  8] = input count holder
;
; Returns: 
;   [ebp + 20] = user-input converted integer
; ---------------------------------------------------------------------------------

ReadVal PROC
    push    EBP
    mov     EBP, ESP

    ; store other registers
    pushad

; --------------------------------
; Getting a string, checking it for valid input that can be converted into a 
;   signed integer that fits in a 32-bit register. 
; --------------------------------
_getString:
    mGetString [EBP + 16], [EBP + 12], [EBP + 8]
    mov     ESI, 0
    mov     EDI, [EBP + 20]
    mov     [EDI], ESI                      ; ensure that our integer data label is zero
    
    ; check if we have a null input
    mov     EAX, [EBP + 8]
    cmp     EAX, 0
    jz      _invalidInput

    ; check if we have too large of a string
    cmp     EAX, INPUT_MAX + 1
    jge     _overflowWarning
    jmp     _startStringValidation

    ; prints out a warning message and then starts over
_invalidInput:
    mDisplayString [EBP + 24]
    jmp _getString

    ; warns that an overflow has occurred 
    ; sets registers to zero then restarts
_overflowWarning:
    mDisplayString [EBP + 28]
    mov     EDI, [EBP + 20]
    mov     ESI, 0
    mov     [EDI], ESI
    xor     EAX,EAX
    xor     EBX,EBX
    xor     ECX,ECX
    xor     EDX,EDX
    xor     ESI,ESI
    xor     EDI,EDI
    jmp     _getString

    ; checks if the string starts with a '-' or '+'
_startStringValidation:
    mov     ECX, [EBP + 8]
    sub     ECX, 1                          ; ECX = number of chars in string - 1                     
    
    ; string offset is still in EDX
    mov     ESI, [EBP + 12]
    cld
    lodsb   
    cmp     AL, 2Bh                         ; '+'
    je      _validateSignedInt
    cmp     AL, 2Dh                         ; '-'
    je      _validateSignedInt
    cmp     AL, 30h                         ; '0'
    jl      _invalidInput  
    cmp     AL, 39h                         ; '9'
    jg      _invalidInput
    jmp     _validateRestOfString           ; no sign, so skip sign check

    ; handles a signed int (rather than no sign entered)
_validateSignedInt:
    cmp     ECX, 0
    jnz     _validateRestOfString
    jz     _invalidInput

    ; validates the rest of the string after accounting for a sign
_validateRestOfString:
    cmp     ECX, 0
    jz      _validString
    lodsb   
    cmp     AL, 30h                         ; '0'
    jl      _invalidInput  
    cmp     AL, 39h                         ; '9'
    jg      _invalidInput
    loop    _validateRestOfString

    ; if we get here then we have a valid string
_validString:
    mov     ECX, [EBP + 8]
    mov     ESI, [EBP + 12]
    cld

; --------------------------------
; Takes the validated string and converts to a signed integer by using string
;   primatives, then moves each digit into the integer data label.
; --------------------------------
_convertToInteger:
    mov     EAX, 4294967295  
    xor     EAX, EAX                        ; set EAX to zero

    lodsb
    cmp     AL, 2Bh
    je      _positiveSignedValue
    cmp     AL, 2Dh 
    je      _negativeSignedValue
    sub     AL, 48                          ; convert ascii char to integer value
    push    EAX
    push    ESI
    mov     ESI, [EBP + 20]
    mov     EAX, [ESI]
    pop     ESI
    mov     EBX, 10
    imul    EBX
    mov     EBX, EAX
    pop     EAX
    add     EBX, EAX
    jo      _overflowWarning                ; check if we've overflowed the 32-bit register
    push    EDI
    mov     EDI, [EBP + 20]
    mov     [EDI], EBX
    pop     EDI
    loop    _convertToInteger
    jmp     _finish

    ; loops after detecting a '+' as the first character
_positiveSignedValue:
    loop    _convertToInteger

    ; jump here if we have a negative number
_negativeSignedValue:
    ; handles the first digit
    ; doesn't check for overflow for the first digit
    sub     ECX, 1
    mov     EAX, 4294967295  
    xor     EAX, EAX                        ; set EAX to zero

    lodsb
    sub     AL, 48                          ; convert ascii char to integer value
    push    EAX
    push    ESI
    mov     ESI, [EBP + 20]
    mov     EAX, [ESI]
    pop     ESI
    mov     EBX, 10
    imul    EBX
    mov     EBX, EAX
    pop     EAX
    neg     EAX
    neg     EBX
    add     EBX, EAX
    push    EDI
    mov     EDI, [EBP + 20]
    mov     [EDI], EBX
    pop     EDI
    sub     ECX, 1
    cmp     ECX, 0
    jz      _finish

    ; begins loop to handle the rest of the digits
_negativeLoop:
    mov     EAX, 4294967295  
    xor     EAX, EAX                        ; set EAX to zero

    lodsb

    sub     AL, 48                          ; convert ascii char to integer value
    push    EAX
    push    ESI
    mov     ESI, [EBP + 20]
    mov     EAX, [ESI]
    pop     ESI
    mov     EBX, 10
    imul    EBX
    mov     EBX, EAX
    pop     EAX
    neg     EAX
    add     EBX, EAX
    jo      _overflowWarning                ; check if we've overflowed the 32-bit register
    push    EDI
    mov     EDI, [EBP + 20]
    mov     [EDI], EBX
    pop     EDI
    loop    _negativeLoop
    jmp     _finish

    ; [ebp + 20] now holds the finished integer after conversion
    ; pop all original registers and return
_finish:
    popad
    pop     EBP
    RET     24
ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Receives an integer, then converts it to a string. Prints the string using 
;   the mDisplayString macro. Uses int_length as LOCAL variable.
;
; Preconditions: int_length is not used as a global variable
;   string buffers are initialized and pushed via calling procedure
;
; Postconditions: changes registers al, eax, ebx, ecx, edi, edx, esi and restores from stack
;   output_string holds the finished string after printing
;
; Receives:
;   [ebp + 16] = output string placeholder
;   [ebp + 12] = buffer for reversing string
;   [ebp +  8] = input integer
;
; Returns: prints converted integer to console
; ---------------------------------------------------------------------------------
WriteVal PROC
LOCAL int_length:DWORD

    ; store other registers
    pushad

    ; setup placeholders for string conversion
    ; add a '-' to new string if negative integer is given
    mov     ESI, [EBP + 8]                  ; ESI = input integer to convert to string
    mov     EDI, [EBP + 16]         
    push    EDI                             ; push final string location for EDI use later
    mov     EDI, [EBP + 12]                 ; EDI = location of reversed string buffer
    mov     EBX, 10                         ; EBX = divisor
    mov     int_length, 0
    cld

    mov     EAX, ESI
    cmp     EAX, 0                          
    je      _intZero                        ; jump if integer is zero
    jg      _postSign                       ; jump if integer is positive

    ; add minus sign if negative to final string destination
    pop     EDI
    push    EAX
    mov     AL, 2Dh                         ; directly add minus-sign to string buffer start
    stosb  
    pop     EAX
    push    EDI                             ; push location of destination string after adding '-'
    mov     EDI, [EBP + 12]
    jmp     _postSign

    ; if the integer is exactly zero, jump to reversing section
_intZero:
    add     EAX, 48
    stosb 
    inc     int_length
    jmp      _reverseString

; --------------------------------
; Divides the integer by 10 to store each digit as a string character. Uses the
;   remainder for the character, then loops with the quotient. Stops looping
;   once the end of the string is reached.
; --------------------------------
_postSign:
    cmp     EAX, 0
    jz      _reverseString

    cdq     
    idiv    EBX
    push    EAX
    mov     EAX, EDX
    cmp     EAX, 0
    jge     _appendPositiveDigit            ; don't negate if not negative
    neg     EAX

_appendPositiveDigit:
    add     EAX, 48
    stosb   
    pop     EAX                             ; EAX is the quotient
    inc     int_length
    jmp    _postSign

; --------------------------------
; Takes the string we just created and reverses it to create the final string
;   to be printed. Uses string primitives to reverse the string, then uses the
;   mDisplayString macro to print.
; --------------------------------
_reverseString:
    mov     ESI, [EBP + 12]                 ; ESI = reversed-string buffer
    add     ESI, int_length
    dec     ESI
    pop     EDI                             ; EDI = destination string buffer, account for '-'
    mov     ECX, int_length     

    ; reverse loop
_reversing:
    std
    lodsb
    cld
    stosb
    loop    _reversing
    mov     AL, 0
    stosb

    ; prints the finalized string
    mDisplayString [EBP + 16] 

    ; returns
    popad
    RET     12
WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: introduction
;
; Greets the user, presenting them with the function and purpose of the program.
;
; Preconditions: strings are passed as BYTE array offsets
;
; Postconditions: changes register edx
;
; Recieves: message strings stored in global variables
;   [ebp + 28] = instruct_4
;   [ebp + 24] = instruct_3
;   [ebp + 20] = instruct_2
;   [ebp + 16] = instruct_1
;   [ebp + 12] = program_author
;   [ebp +  8] = program_title
;
; Returns: prints introduction messages to console
; ---------------------------------------------------------------------------------
introduction PROC
    push    EBP
    mov     EBP, ESP
      
    mDisplayString [EBP + 8]
    mDisplayString [EBP + 12]       
    mDisplayString [EBP + 16]
    mDisplayString [EBP + 20]
    mDisplayString [EBP + 24]
    mDisplayString [EBP + 28]

    pop     EBP
    RET     24

introduction ENDP


; ---------------------------------------------------------------------------------
; Name: farewell
;
; Says goodbye to the user.
;
; Preconditions: strings are passed as BYTE array offsets
;
; Postconditions: changes register edx
;
; Recieves: TODO:
;   [ebp + 12] = farewell_msg_2
;   [ebp +  8] = farewell_msg_1
;
; Returns: prints farewell messages to console
; ---------------------------------------------------------------------------------
farewell PROC
    push    EBP
    mov     EBP, ESP

    mDisplayString [EBP + 8]
    mDisplayString [EBP + 12]

    pop     EBP
    RET     8 

farewell ENDP


END main