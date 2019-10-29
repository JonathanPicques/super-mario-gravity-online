@echo off
CD /d "Build"

:: Ask how many client to start
SET /P "CLIENT_COUNT=How many clients [2]?" || SET "CLIENT_COUNT=2"

:: Start server
START "Build" "Super Mario Gravity Online.exe" --server

:: Add a delay until server is started
PING localhost -n 2 >NULL

:: Start clients
FOR /L %%G IN (1, 1, %CLIENT_COUNT%) DO (
	START "Build" "Super Mario Gravity Online.exe" --client
)