@echo off
CD /d "Build"

:: Ask how many client to start
SET /P "CLIENT_COUNT=How many clients [default: 1]?" || SET "CLIENT_COUNT=1"

:: Start server
START "Build" "Frog.exe" --server

:: Add a delay until server is started
PING localhost -n 2 >NUL

:: Start clients
FOR /L %%G IN (1, 1, %CLIENT_COUNT%) DO (
	START "Build" "Frog.exe" --client
)