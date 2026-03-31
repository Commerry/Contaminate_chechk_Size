; PSE Vision System - NSIS Installer Script
; This script customizes the installer behavior

!macro customInit
  ; Check if old version is installed
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\{com.pse.vision.worker}" "UninstallString"
  
  ${If} $0 != ""
    ; Old version found - ask user
    MessageBox MB_YESNO|MB_ICONQUESTION "พบโปรแกรมเวอร์ชันเก่าติดตั้งอยู่$\n$\nต้องการถอนการติดตั้งเวอร์ชันเก่าอัตโนมัติหรือไม่?$\n$\n(แนะนำให้เลือก Yes เพื่อป้องกันความขัดแย้ง)" IDYES uninstall_old IDNO skip_uninstall
    
    uninstall_old:
      ; Kill running processes
      DetailPrint "Closing running PSE Vision application..."
      nsExec::ExecToLog 'taskkill /F /IM "PSE Vision Worker Display.exe" /T'
      Sleep 2000
      
      ; Run uninstaller silently
      DetailPrint "Uninstalling old version..."
      ClearErrors
      ExecWait '$0 /S _?=$INSTDIR'
      Sleep 2000
      
      ; Clean up any leftover files
      RMDir /r "$INSTDIR\logs"
      RMDir /r "$INSTDIR\datasets"
      Delete "$INSTDIR\INSTALLATION_INFO.txt"
      Delete "$INSTDIR\START_SYSTEM.bat"
      
      DetailPrint "Old version removed successfully"
      Goto continue_install
    
    skip_uninstall:
      MessageBox MB_OK "การติดตั้งจะดำเนินการต่อ$\n$\nหากพบปัญหา กรุณาถอนโปรแกรมเก่าด้วยตนเอง"
  ${EndIf}
  
  continue_install:
  ; Show installer message
  MessageBox MB_OK "PSE Vision System Installer$\n$\nThis will install:$\n- Desktop App (Worker Display)$\n- Admin Web Interface (Port 64020)$\n- Backend API (Port 64020)$\n- Auto-start on Windows boot"
!macroend

!macro customInstall
  ; Create additional folders
  CreateDirectory "$INSTDIR\logs"
  CreateDirectory "$INSTDIR\models"
  CreateDirectory "$INSTDIR\datasets"
  
  ; Copy installation info
  FileOpen $0 "$INSTDIR\INSTALLATION_INFO.txt" w
  FileWrite $0 "PSE Vision System - Installation Information$\r$\n"
  FileWrite $0 "==========================================$\r$\n$\r$\n"
  FileWrite $0 "Installation Date: ${__DATE__} ${__TIME__}$\r$\n"
  FileWrite $0 "Installation Path: $INSTDIR$\r$\n$\r$\n"
  FileWrite $0 "Components Installed:$\r$\n"
  FileWrite $0 "- Desktop App (Electron): Yes$\r$\n"
  FileWrite $0 "- Admin Web (Vue.js): Yes$\r$\n"
  FileWrite $0 "- Backend API (Python Flask): Yes$\r$\n"
  FileWrite $0 "- Configuration Files: Yes$\r$\n"
  FileWrite $0 "- Offline Packages: Yes$\r$\n$\r$\n"
  FileWrite $0 "System Configuration:$\r$\n"
  FileWrite $0 "- Backend Port: 64020$\r$\n"
  FileWrite $0 "- Admin Web Port: 64020$\r$\n"
  FileWrite $0 "- Auto-start: Enabled (starts on Windows boot)$\r$\n"
  FileWrite $0 "- Single Instance: Enabled (no duplicate programs)$\r$\n$\r$\n"
  FileWrite $0 "To start the system:$\r$\n"
  FileWrite $0 "1. System auto-starts on Windows boot$\r$\n"
  FileWrite $0 "2. Or run: PSE Vision Worker Display (desktop shortcut)$\r$\n"
  FileWrite $0 "3. Manual backend start: START_BACKEND.bat$\r$\n$\r$\n"
  FileWrite $0 "Access URLs:$\r$\n"
  FileWrite $0 "- Admin Web: http://localhost:64020$\r$\n"
  FileWrite $0 "- Backend API: http://localhost:64020$\r$\n$\r$\n"
  FileWrite $0 "Documentation: $INSTDIR\docs\$\r$\n"
  FileWrite $0 "Support: PSE Vision Team$\r$\n"
  FileClose $0
  
  ; Create backend start script
  FileOpen $0 "$INSTDIR\START_BACKEND.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "cd /d %~dp0$\r$\n"
  FileWrite $0 "echo Starting Backend API on port 64020...$\r$\n"
  FileWrite $0 "cd resources\python_scripts$\r$\n"
  FileWrite $0 "set FLASK_PORT=64020$\r$\n"
  FileWrite $0 "python backend_server.py$\r$\n"
  FileWrite $0 "pause$\r$\n"
  FileClose $0
  
  ; Create system start script
  FileOpen $0 "$INSTDIR\START_SYSTEM.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "echo ======================================$\r$\n"
  FileWrite $0 "echo PSE Vision System - Starting...$\r$\n"
  FileWrite $0 "echo ======================================$\r$\n"
  FileWrite $0 "echo.$\r$\n"
  FileWrite $0 "cd /d %~dp0$\r$\n"
  FileWrite $0 "echo [1/2] Starting Backend API on port 64020...$\r$\n"
  FileWrite $0 "start $\"Backend API$\" cmd /k $\"cd resources\python_scripts && set FLASK_PORT=64020 && python backend_server.py$\"$\r$\n"
  FileWrite $0 "timeout /t 5 /nobreak$\r$\n"
  FileWrite $0 "echo.$\r$\n"
  FileWrite $0 "echo [2/2] Starting Desktop App...$\r$\n"
  FileWrite $0 "start $\"$\" $\"%~dp0${productName}.exe$\"$\r$\n"
  FileWrite $0 "echo.$\r$\n"
  FileWrite $0 "echo System started successfully!$\r$\n"
  FileWrite $0 "echo Admin Web: http://localhost:64020$\r$\n"
  FileWrite $0 "echo.$\r$\n"
  FileWrite $0 "pause$\r$\n"
  FileClose $0
  
  ; Create desktop shortcut for START_SYSTEM.bat
  CreateShortcut "$DESKTOP\Start PSE Vision.lnk" "$INSTDIR\START_SYSTEM.bat" "" "$INSTDIR\resources\app\public\Logo_checksize.ico" 0
!macroend

!macro customUnInstall
  ; Kill running processes before uninstall
  DetailPrint "Stopping PSE Vision application..."
  nsExec::ExecToLog 'taskkill /F /IM "PSE Vision Worker Display.exe" /T'
  Sleep 1000
  
  DetailPrint "Stopping Backend API..."
  nsExec::ExecToLog 'taskkill /F /IM "python.exe" /FI "WINDOWTITLE eq Backend*" /T'
  Sleep 1000
  
  ; Remove additional folders
  RMDir /r "$INSTDIR\logs"
  RMDir /r "$INSTDIR\datasets"
  
  ; Remove created scripts
  Delete "$INSTDIR\START_SYSTEM.bat"
  Delete "$INSTDIR\START_BACKEND.bat"
  Delete "$INSTDIR\INSTALLATION_INFO.txt"
  
  ; Remove desktop shortcuts
  Delete "$DESKTOP\Start PSE Vision.lnk"
  
  DetailPrint "PSE Vision uninstalled successfully"
!macroend
