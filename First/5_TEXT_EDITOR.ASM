; -------------------------------------------------------------------------------------

 format PE GUI 4.0

 entry win_main

 include 'win32a.inc'

; -------------------------------------------------------------------------------------

 IDR_MY_MENU = 1

 IDM_FILE = 100
 IDM_NEW = 101
 IDM_OPEN = 102
 IDM_SAVE = 103
 IDM_SAVE_AS = 104
 IDM_EXIT = 105

 IDR_ACCEL = 106
 ID_SELECT_ALL = 107

; -------------------------------------------------------------------------------------

 section '.code' code readable executable

  win_main:

        ; initialise the members of the wcex structure

        ; --------------------------------------------

        ; WNDCLASSEX

        ; UINT cbSize
        ; UINT style
        ; WNDPROC lpfnWndProc
        ; int cbClsExtra
        ; int cbWndExtra
        ; HINSTANCE hInstance
        ; HICON hIcon
        ; HCURSOR hCursor
        ; HBRUSH hbrBackground
        ; LPCTSTR lpszMenuName
        ; LPCTSTR lpszClassName
        ; HICON hIconSm

        ; --------------------------------------------

        ; the instance handle

        invoke GetModuleHandle,0

        mov [wcex.hInstance],eax

        ; cbSize

        mov eax,sizeof.WNDCLASSEX

        mov [wcex.cbSize],eax

        ; the windows proc

        mov [wcex.lpfnWndProc],WndProc

        ; the windows style

        mov [wcex.style],CS_HREDRAW+CS_VREDRAW

        ; load the icons

        invoke LoadIcon,[wcex.hInstance],IDI_APPLICATION

        mov [wcex.hIcon],eax

        mov [wcex.hIconSm],eax

        ; load the cursor

        invoke LoadCursor,NULL,IDC_ARROW

        mov [wcex.hCursor],eax

        ; the brush for the background

        mov [wcex.hbrBackground],COLOR_BTNFACE+1

        ; the windows class name

        mov dword [wcex.lpszClassName],szClass

        ; set to NULL

        mov [wcex.cbClsExtra],0

        mov [wcex.cbWndExtra],0

        mov dword [wcex.lpszMenuName],NULL

        ; register wcex

        ; RegisterClassEx(&wcex)

        invoke RegisterClassEx,wcex

        test eax,eax

        jz reg_error

        ; load the menu

        invoke LoadMenu,[wcex.hInstance],IDR_MY_MENU

        mov [h_menu],eax

        ; create the main window

        invoke CreateWindowEx,0,szClass,szTitle,WS_OVERLAPPEDWINDOW,\
                              CW_USEDEFAULT,CW_USEDEFAULT,\
                              700,500,NULL,[h_menu],[wcex.hInstance],NULL

        ; save the windows handle:

        mov [h_wnd],eax

        test eax,eax

        jz cr_error

        ; load the accelerator table

        invoke LoadAccelerators,[wcex.hInstance],IDR_ACCEL

        test eax,eax

        jz acc_error

        mov [h_accel],eax

        ; show and update the window

        ; ShowWindow(hWnd,SW_SHOWNORMAL)

        invoke ShowWindow,[h_wnd],SW_SHOWNORMAL

        ; UpdateWindow(hWnd)

        invoke UpdateWindow,[h_wnd]

  msg_loop:

        ; the main message loop

        ; GetMessage(&msg,NULL,0,0)

        invoke GetMessage,msg,NULL,0,0

        cmp eax,1

        jb exit

        jne msg_loop

        ; TranslateAccelerator(hwnd,h_accel,&msg)

        invoke TranslateAccelerator,[h_wnd],[h_accel],msg

        test eax,eax

        ; no need to call TranslateMessage and DispatchMessage,

        ; if an accelerator is successfully translated

        jnz msg_loop

        ; TranslateMessage(&msg)

        invoke TranslateMessage,msg

        ; DispatchMessage(&msg)

        invoke DispatchMessage,msg

        jmp msg_loop

  reg_error:

        invoke MessageBox,NULL,szRegError,szTitle,MB_ICONERROR+MB_OK

        jmp exit

  cr_error:

        invoke MessageBox,NULL,szCreateError,szTitle,MB_ICONERROR+MB_OK

        jmp exit

  acc_error:

        invoke MessageBox,NULL,szAccelError,szTitle,MB_ICONERROR+MB_OK

  exit:

        ; return msg.wParam

        invoke ExitProcess,[msg.wParam]

; -------------------------------------------------------------------------------------

proc WndProc uses ebx esi edi,hwnd,wmsg,wparam,lparam

  ; WndProc(hwnd,wmsg,wparam,lparam)

  ; callback function to process messages for the main window

        cmp [wmsg],WM_CREATE

        je .ON_CREATE

        cmp [wmsg],WM_SIZE

        je .SIZE

        cmp [wmsg],WM_SETFOCUS

        je .SET_FOCUS

        cmp [wmsg],WM_COMMAND

        je .COMMAND

        cmp [wmsg],WM_DESTROY

        je .DESTROY

  .DEFAULT:

        ; DefWindowProc(hWnd,wmsg,wParam,lParam)

        invoke DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]

        jmp .DONE

  .ON_CREATE:

        ; create the child EDIT control

        invoke CreateWindowEx,WS_EX_CLIENTEDGE,szEdit,0,\
        WS_VISIBLE+WS_CHILD+WS_VSCROLL+ES_AUTOVSCROLL+ES_MULTILINE,\
        0,0,0,0,[hwnd],0,[wcex.hInstance],NULL

        test eax,eax

        jz .EDIT_FAILED

        mov [h_wnd_edit],eax

        ; create a font for the edit control

        invoke CreateFont,18,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,ANSI_CHARSET,\
        OUT_DEVICE_PRECIS,CLIP_DEFAULT_PRECIS,PROOF_QUALITY,FIXED_PITCH+FF_DONTCARE,szFontFace

        test eax,eax

        jz .FONT_FAILED

        mov [h_font],eax

        invoke SendMessage,[h_wnd_edit],WM_SETFONT,[h_font],FALSE

        xor eax,eax

        jmp .DONE

  .EDIT_FAILED:

        invoke MessageBox,NULL,szCreateError,szTitle,MB_ICONERROR+MB_OK

        jmp .DONE

  .FONT_FAILED:

        invoke MessageBox,NULL,szFontError,szTitle,MB_ICONERROR+MB_OK

        jmp .DONE

  .SIZE:

        ; resize the child window

        ; new width = LOWORD(lParam)

        ; new height = HIWORD(lParam)

        mov eax,[lparam]

        and eax,0xffff

        mov edx,[lparam]

        shr edx,16

        invoke MoveWindow,[h_wnd_edit],0,0,eax,edx,TRUE

        xor eax,eax

        jmp .DONE

  .SET_FOCUS:

        ; set the focus to the child EDIT control

        invoke SetFocus,[h_wnd_edit]

        xor eax,eax

        jmp .DONE

  .COMMAND:

        mov eax,[wparam]

        and eax,0xffff

        cmp eax,IDM_NEW

        je .NEW

        cmp eax,IDM_OPEN

        je .OPEN

        cmp eax,IDM_SAVE

        je .SAVE

        cmp eax,IDM_SAVE_AS

        je .SAVE_AS

        cmp eax,IDM_EXIT

        je .DESTROY

        cmp eax,ID_SELECT_ALL

        je .SELECT_ALL

        jmp .DEFAULT

  .NEW:

        ; File|New or CTRL+N

        ; clear the Edit window

        invoke SendMessage,[h_wnd_edit],WM_SETTEXT,0,0

        invoke SetWindowText,[hwnd],szTitle

        ; reset the file name

        lea esi,[szFileName]

        mov [esi],byte 0

        xor eax,eax

        jmp .DONE

  .OPEN:

        ; File|Open or CTRL+O

        stdcall File_Open,[hwnd]

        test eax,eax

        jz .DONE

        ; load the file contents into the Edit window

        stdcall Text_From_File

        invoke SetWindowText,[hwnd],szFileName

        xor eax,eax

        jmp .DONE

  .SAVE:

        ; File|Save or CTRL+S

        ; if there isn't a valid file name,

        ; call the File Save As dialog

        cmp [szFileName],byte 0

        jnz .TXT_TO_FILE

        stdcall File_Save_As,[hwnd]

        test eax,eax

        jz .DONE

        invoke SetWindowText,[hwnd],szFileName

  .TXT_TO_FILE:

        ; save the Edit window text to the file

        stdcall Text_To_File

        xor eax,eax

        jmp .DONE

  .SAVE_AS:

        ; File|Save As

        stdcall File_Save_As,[hwnd]

        test eax,eax

        jz .DONE

        invoke SetWindowText,[hwnd],szFileName

        ; save the Edit window text to the file

        stdcall Text_To_File

        xor eax,eax

        jmp .DONE

  .SELECT_ALL:

        ; CTRL+A (via Accerlerator Table)

        invoke SendMessage,[h_wnd_edit],EM_SETSEL,0,-1

        xor eax,eax

        jmp .DONE

  .DESTROY:

        ; destroy the font

        invoke DeleteObject,[h_font]

        ; PostQuitMessage(0)

        invoke PostQuitMessage,0

        xor eax,eax

  .DONE:

        ret

endp

; -------------------------------------------------------------------------------------

proc File_Open,hwnd

  ; display the GetOpenFileName dialog to get the file name

  ; then load the contents of the file into the Edit window

        ; zero ofn - the OPENFILENAME struct

        mov eax,sizeof.OPENFILENAME

        cinvoke memset,ofn,0,eax

        ; initialise the members of ofn

        mov eax,sizeof.OPENFILENAME

        mov [ofn.lStructSize],eax

        mov eax,[hwnd]

        mov [ofn.hwndOwner],eax

        ; the filter

        mov eax,szFilter

        mov [ofn.lpstrFilter],eax

        lea eax,[szFileName]

        mov [ofn.lpstrFile],eax

        mov eax,MAX_PATH

        mov [ofn.nMaxFile],eax

        mov eax,OFN_EXPLORER
        or eax,OFN_FILEMUSTEXIST
        or eax,OFN_HIDEREADONLY

        mov [ofn.Flags],eax

        mov eax,szDefFileExtension

        mov [ofn.lpstrDefExt],eax

        ; display the dialog to get szFileName

        invoke GetOpenFileName,ofn

        ret

endp

; -------------------------------------------------------------------------------------

proc File_Save_As,hwnd

  ; display the GetSaveFileName dialog to get the file name

  ; then save the contents of the Edit window to the file

        ; zero ofn - the OPENFILENAME struct

        mov eax,sizeof.OPENFILENAME

        cinvoke memset,ofn,0,eax

        ; initialise the members of ofn

        mov eax,sizeof.OPENFILENAME

        mov [ofn.lStructSize],eax

        mov eax,[hwnd]

        mov [ofn.hwndOwner],eax

        ; the filter

        mov eax,szFilter

        mov [ofn.lpstrFilter],eax

        lea eax,[szFileName]

        mov [ofn.lpstrFile],eax

        mov eax,MAX_PATH

        mov [ofn.nMaxFile],eax

        mov eax,OFN_EXPLORER
        or eax,OFN_PATHMUSTEXIST
        or eax,OFN_HIDEREADONLY
        or eax,OFN_OVERWRITEPROMPT

        mov [ofn.Flags],eax

        mov eax,szDefFileExtension

        mov [ofn.lpstrDefExt],eax

        ; display the dialog to get szFileName

        invoke GetSaveFileName,ofn

        ret

endp

; -------------------------------------------------------------------------------------

proc Text_From_File uses ebx esi edi

  ; load the contents of the file into the Edit window

        ; get a handle to the default heap for this process

        invoke GetProcessHeap

        test eax,eax

        jz .HEAP_FAILED

        mov [h_heap],eax

        ; open the file

        invoke CreateFile,szFileName,GENERIC_READ,FILE_SHARE_READ,NULL,\
        OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL

        test eax,eax

        jz .CRF_FAILED

        ; get the file handle

        mov [h_file],eax

        ; get the file size

        invoke GetFileSize,[h_file],NULL

        cmp eax,0xffffffff

        je .INVALID_SIZE

        mov [FileSize],eax

        ; allocate (FileSize + 1) bytes, with the extra byte for the null terminator

        inc eax

        ; allocate nBytes from the heap for the buffer

        invoke HeapAlloc,[h_heap],NULL,eax

        test eax,eax

        jz .ALLOC_FAILED

        ; point pFileBuffer to the buffer

        mov [pFileBuffer],eax

        ; read the contents of the file into the buffer

        invoke ReadFile,[h_file],[pFileBuffer],[FileSize],nBytes,NULL

        test eax,eax

        jz .READ_FAILED

        ; null terminate the file buffer

        mov esi,[pFileBuffer]

        add esi,[FileSize]

        mov [esi],byte 0

        ; set the text of the Edit window

        invoke SetWindowText,[h_wnd_edit],[pFileBuffer]

  .FREE:

        invoke HeapFree,[h_heap],NULL,[pFileBuffer]

  .HCLOSE:

        invoke CloseHandle,[h_file]

        jmp .DONE

  .READ_FAILED:

        invoke MessageBox,NULL,szReadError,szTitle,MB_ICONERROR+MB_OK

        jmp .FREE

  .INVALID_SIZE:

        invoke MessageBox,NULL,szSizeError,szTitle,MB_ICONERROR+MB_OK

        jmp .HCLOSE

  .ALLOC_FAILED:

        invoke MessageBox,NULL,szAllocError,szTitle,MB_ICONERROR+MB_OK

        jmp .HCLOSE

  .CRF_FAILED:

        invoke MessageBox,NULL,szFileError,szTitle,MB_ICONERROR+MB_OK

        jmp .DONE

  .HEAP_FAILED:

        invoke MessageBox,NULL,szHeapError,szTitle,MB_ICONERROR+MB_OK

  .DONE:

        ret

endp

; -------------------------------------------------------------------------------------

proc Text_To_File uses ebx esi edi

  ; save the contents of the Edit window to the file

        ; get a handle to the default heap for this process

        invoke GetProcessHeap

        test eax,eax

        jz .HEAP_FAILED

        mov [h_heap],eax

        ; get the number of bytes in the Edit window

        invoke GetWindowTextLength,[h_wnd_edit]

        ; +1 for the null terminator

        inc eax

        mov [nBytes],eax

        ; allocate nBytes from the heap for the buffer

        invoke HeapAlloc,[h_heap],NULL,eax

        test eax,eax

        jz .ALLOC_FAILED

        ; point pFileBuffer to the buffer

        mov [pFileBuffer],eax

        ; open the file, create it if it doesn't exist

        invoke CreateFile,szFileName,GENERIC_WRITE,0,NULL,\
        CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL

        test eax,eax

        jz .CRF_FAILED

        ; get the file handle

        mov [h_file],eax

        ; read the contents of the Edit window into the buffer

        invoke GetWindowText,[h_wnd_edit],[pFileBuffer],[nBytes]

        ; EAX now contains the size of pFileBuffer, not including the null terminator

        ; write the buffer to the file

        invoke WriteFile,[h_file],[pFileBuffer],eax,nBytes,NULL

  .HCLOSE:

        invoke CloseHandle,[h_file]

  .FREE:

        invoke HeapFree,[h_heap],NULL,[pFileBuffer]

        jmp .DONE

  .ALLOC_FAILED:

        invoke MessageBox,NULL,szAllocError,szTitle,MB_ICONERROR+MB_OK

        jmp .DONE

  .CRF_FAILED:

        invoke MessageBox,NULL,szFileError,szTitle,MB_ICONERROR+MB_OK

        jmp .FREE

  .HEAP_FAILED:

        invoke MessageBox,NULL,szHeapError,szTitle,MB_ICONERROR+MB_OK

  .DONE:

        ret

endp

; -------------------------------------------------------------------------------------

section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
          user,'USER32.DLL',\
          comdlg32,'COMDLG32.DLL',\
          gdi,'GDI32.DLL',\
          msvcrt,'MSVCRT.DLL'

  import kernel,\
         GetModuleHandle,'GetModuleHandleA',\
         ExitProcess,'ExitProcess',\
         GetFileSize,'GetFileSize',\
         CloseHandle,'CloseHandle',\
         CreateFile,'CreateFileA',\
         ReadFile,'ReadFile',\
         WriteFile,'WriteFile',\
         GetProcessHeap,'GetProcessHeap',\
         HeapAlloc,'HeapAlloc',\
         HeapFree,'HeapFree'

  import user,\
         RegisterClassEx,'RegisterClassExA',\
         CreateWindowEx,'CreateWindowExA',\
         ShowWindow,'ShowWindow',\
         UpdateWindow,'UpdateWindow',\
         MoveWindow,'MoveWindow',\
         GetMessage,'GetMessageA',\
         SendMessage,'SendMessageA',\
         TranslateMessage,'TranslateMessage',\
         DispatchMessage,'DispatchMessageA',\
         MessageBox,'MessageBoxA',\
         DefWindowProc,'DefWindowProcA',\
         PostQuitMessage,'PostQuitMessage',\
         SetFocus,'SetFocus',\
         LoadIcon,'LoadIconA',\
         LoadMenu,'LoadMenuA',\
         LoadCursor,'LoadCursorA',\
         SetWindowText,'SetWindowTextA',\
         GetWindowText,'GetWindowTextA',\
         GetWindowTextLength,'GetWindowTextLengthA',\
         LoadAccelerators,'LoadAcceleratorsA',\
         TranslateAccelerator,'TranslateAcceleratorA'

  import comdlg32,\
         GetOpenFileName,'GetOpenFileNameA',\
         GetSaveFileName,'GetSaveFileNameA'

  import gdi,\
         CreateFont,'CreateFontA',\
         DeleteObject,'DeleteObject'

  import msvcrt,\
         memset,'memset'

; -------------------------------------------------------------------------------------

section '.data' readable writeable

  szClass TCHAR "Win32app",0

  szTitle TCHAR "Text Editor",0 

  szEdit TCHAR "EDIT",0

  szRegError TCHAR "Call to RegisterClassEx failed!",0

  szCreateError TCHAR "Call to CreateWindowEx failed!",0

  szFontError TCHAR "Call to CreateFont failed!",0

  szFileError TCHAR "Call to CreateFile failed!",0

  szReadError TCHAR "Call to ReadFile failed!",0

  szAllocError TCHAR "Call to HeapAlloc failed!",0

  szHeapError TCHAR "Call to GetProcessHeap failed!",0

  szSizeError TCHAR "Call to GetFileSize failed!",0

  szAccelError TCHAR "Call to LoadAccelerators failed!",0

  szFontFace TCHAR "Lucida Console",0

  szDefFileExtension TCHAR "txt",0

  ; Note that the filter string is double null terminated:

  szFilter TCHAR "Text Files (*.txt)",0,"*.txt",0,"All Files (*.*)",0,"*.*",0,0

  szFileName rb MAX_PATH

  ofn OPENFILENAME

  wcex WNDCLASSEX

  msg MSG

  h_wnd dd 0

  h_wnd_edit dd 0

  h_font dd 0

  h_menu dd 0

  h_file dd 0

  h_heap dd 0

  h_accel dd 0

  FileSize dd 0

  nBytes dd 0

  pFileBuffer dd 0

; -------------------------------------------------------------------------------------

section '.rc' resource data readable

  directory RT_MENU,menus,\
            RT_ACCELERATOR,accelerators

  resource menus,IDR_MY_MENU,LANG_ENGLISH+SUBLANG_DEFAULT,my_menu

  resource accelerators,IDR_ACCEL,LANG_ENGLISH+SUBLANG_DEFAULT,accel_keys

  menu my_menu

  menuitem 'File',IDM_FILE,MFR_POPUP+MFR_END
  menuitem 'New',IDM_NEW
  menuitem 'Open',IDM_OPEN
  menuitem 'Save',IDM_SAVE
  menuitem 'Save As',IDM_SAVE_AS
  menuseparator
  menuitem 'Exit',IDM_EXIT,MFR_END

  accelerator accel_keys,\
              FVIRTKEY+FNOINVERT+FCONTROL,'N',IDM_NEW,\
              FVIRTKEY+FNOINVERT+FCONTROL,'O',IDM_OPEN,\
              FVIRTKEY+FNOINVERT+FCONTROL,'S',IDM_SAVE,\
              FVIRTKEY+FNOINVERT+FCONTROL,'A',ID_SELECT_ALL

; -------------------------------------------------------------------------------------