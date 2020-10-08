format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'Input the size of vector, please: ', 0
        strIncorSize db 'Incorrect size of vector', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strReverseValue  db 'ReverseVec', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        count        dd 0
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vec          rd 100
        new_vec      rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 2) create reverse vector
        call VectorReverse
; 3) reverse vector out
        push strReverseValue
        call [printf]
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 100
        jg  failSize
        cmp eax, 0
        jb  failSize
        cmp eax, 0
        jg  getVector
failSize:
        push vec_size
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]

getVector:
        xor ecx, ecx
        mov ebx, vec
        add [count], -4
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add [count], 4
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorReverse:
        xor ecx, ecx
        mov ebx, vec
        mov edx, new_vec
        add ebx, [count]


reverseVecLoop:
        cmp ecx, [vec_size]
        je endReverseVector
        mov eax, 0
        add eax, [ebx]
        mov [edx], eax

        inc ecx
        add ebx, -4
        add edx, +4
        jmp reverseVecLoop
endReverseVector:
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, new_vec
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'