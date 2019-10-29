@echo off

:: Kill process
TASKKILL.exe /F /IM "Super Mario Gravity Online.exe"

:: Create build folder
MKDIR "Build"

:: Remove binaries
DEL /Q "Build\*"

:: Export new Super Mario Gravity Online binary
"%GODOT_EXECUTABLE%" --export-debug "Windows Desktop" "Build\Super Mario Gravity Online.exe"

:: Run client/server
Dedicated.bat