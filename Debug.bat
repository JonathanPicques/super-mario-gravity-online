@echo off

:: Kill process
TASKKILL.exe /F /IM "Frog.exe"

:: Create build folder
MKDIR "Build"

:: Remove binaries
DEL /Q "Build\*"

:: Export new binary
"%GODOT_EXECUTABLE%" --export-debug "Windows Desktop" "Build\Frog.exe"

:: Run client/server
Dedicated.bat