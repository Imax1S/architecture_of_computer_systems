
include 'win32ax.inc' ; you can simply switch between win32ax, win32wx, win64ax and win64wx here

.data
msg_title db "Welcome", 0
msg_message db "Hello, assembler?", 0
 
.code
        start:
                invoke MessageBox, 0, addr msg_message, addr msg_title, MB_OK
                invoke ExitProcess, 0
        .end start
