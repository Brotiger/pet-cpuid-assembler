TITLE CPUID
.586

.MODEL FLAT, STDCALL

INCLUDELIB lib/import32.lib

EXTRN GetStdHandle: PROC
EXTRN WriteConsoleA: PROC
EXTRN ExitProcess: PROC

Std_Output_Handle EQU -11

.DATA
    Handl_Out DD ?
    Lens DW ?
    Not_Supp DB 'CPUID not supported', 13, 10, '$'
    Not_Supp_L = $ - Not_Supp - 1
    Supp DB 'CPUID supported', 13, 10, '$'
    Supp_L = $ - Supp - 1
    Str1 DB 'Signature: ','$'
    Str1_L = $ - Str1 - 1
    Number DD ?
    Number_Str DB 32 dup (0)
    Number_Str_L = 32

.CODE
    Preobr PROC
        mov EAX, Number
        mov EBX, 2

        xor ECX, ECX

        mov ECX, 32
        xor ESI, ESI
        m1: xor EDX, EDX
            div EBX
            add EDX, 30h
            mov Number_Str[ESI], DL
            inc ESI
        loop m1
        ret
    Preobr ENDP

Start:
    call GetStdHandle, Std_Output_Handle
    mov Handl_Out, EAX
    pushfd
    pop EAX
    mov EBX, EAX
    xor EAX, 200000h
    push EAX
    popfd
    pushfd
    pop EAX
    cmp EAX, EBX
    jne CPUIDSupp

    call WriteConsoleA, Handl_Out, offset Not_Supp, Not_Supp_L, offset Lens, 0
    jmp @exit

    CPUIDSupp:
    call WriteConsoleA, Handl_Out, offset Supp, Supp_L, offset Lens, 0

    mov EAX, 1
    cpuid

    mov Number, EAX
    call Preobr

    call WriteConsoleA, Handl_Out, offset Str1, Str1_L, offset Lens, 0
    call WriteConsoleA, Handl_Out, offset Number_Str, Number_Str_L, offset Lens, 0

@exit: call ExitProcess
END Start