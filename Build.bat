:: Kill process
TASKKILL.exe /F /IM "Super Mario Gravity Online.exe"

:: Create build folder
MKDIR "Build"

:: Remove binaries
DEL /Q "Build\*"

:: Export new Halo Deathmatch binary
"%GODOT_EXECUTABLE%" --export-debug "Windows Desktop" "Build\Super Mario Gravity Online.exe"