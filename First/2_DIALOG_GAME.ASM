
; example of simplified Windows programming using complex macro features

include 'win32ax.inc' ; you can simply switch between win32ax, win32wx, win64ax and win64wx here

.code

  start:

        invoke  MessageBox,HWND_DESKTOP,"Do you wanna play a little?",invoke GetCommandLine,MB_YESNO

        .if eax = IDYES
                invoke  MessageBox,HWND_DESKTOP,"You won!","Yeaah",MB_OK
                invoke  ExitProcess,0
        .endif
                invoke  MessageBox,HWND_DESKTOP,"You lose","...",MB_OK
        invoke  ExitProcess,0

.end start