@echo off

set batch_home=%~dp0
set function=%~1
set message=%~2

for /f %%d in ('date /t') do set cur_date=%%d
for /f %%m in ('time /t') do set cur_minute=%%m
set cur_time=%cur_date% %cur_minute%
echo %cur_time% %function% %message%
if "%function%"=="" set function=info
if %function%==error call :error 
if %function%==info call :info 
if %function%==debug call :debug
rem echo function name %function% is invalid, it should be error, info or debug, sample: call log-util error "invalid message"
goto :eof

rem function name like error, info or debug should be passed as argument
rem say a.bak call error method, it should be call log-util.bak error

:error
	echo %cur_time% ERROR %message% >> %batch_home%log.txt
	goto :eof
	
:info
	echo %cur_time% INFO %message% >> %batch_home%log.txt
	goto :eof
	
:debug
	echo %cur_time% DEBUG %message% >> %batch_home%log.txt
	goto :eof