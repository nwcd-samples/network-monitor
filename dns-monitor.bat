@echo off

SetLocal enabledelayedexpansion

REM Max PING retry times for a same domain name, due to network issue, some PING may be failed
set /A MAX_RETRY=1
REM If PING succeeded, the last line will starts with it
set PING_RESP_LAST_ROW_PREFIX=最短
REM When pinging, if timeouted, the lines will start with it
set PING_RESP_TIMEOUT_ROW_PREFIX=请求超时。
REM The default PING will repeat 4 times, if the timeout items reach 3 times, ignore it
set /A MAX_TIMEOUT=3
REM If PING run succeeded, the 6th line will inclued current IP, such as 1.2.3.4 的Ping统计信息
set /A PING_RESP_IP_ROW_INDEX=6
REM If PING run succeeded, it wil output 9 lines, EMPTY lines will be filtered out automatically
set /A PING_RESP_TOTAL_ROW_NUMBER=9

set batch_path=%~dp0
rem echo batch path %batch_path%
call %batch_path%log-util.bat debug "dns-monitor.bat working directory is %batch path%"
for /f %%d in (%batch_path%domain-names.txt) do (
	call :inner_loop %%d
	REM sleep 1 second for each domain
	rem echo sleeping 1 second for %%d
	call %batch_path%log-util.bat info "dns-monitor.bat sleeping 1 second"
	timeout /t 1 /nobreak
)
goto :eof

:inner_loop
set domain=%1
echo processing %domain%
for /l %%r IN (1,1,%MAX_RETRY%) do (

	set /A ping_resp_row_number=0
	set /A timeout_row_number=0
	REM Collecting PING output for current domain name
	REM echo collecting PING output for %domain%
	call %batch_path%log-util.bat info "dns-monitor.bat collecting PING output for %domain%"
	for /f %%i IN ('ping %domain%') do (
		set /A ping_resp_row_number+=1
		set ping_resp_row[!ping_resp_row_number!]=%%i
		if %%i==%PING_RESP_TIMEOUT_ROW_PREFIX% set /A timeout_row_number+=1
		call %batch_path%log-util.bat debug "dns-monitor.bat ip output: %%i"
	)
	REM Analysing PING output for current domain name
	REM echo analysing PING output for %domain%
	call %batch_path%log-util.bat info "dns-monitor.bat analysing PING output for %domain%"
	if !ping_resp_row_number! equ %PING_RESP_TOTAL_ROW_NUMBER% (
		if !timeout_row_number! equ %MAX_TIMEOUT% (
			REM echo Received max timeout number,ignore this IP and retry automatically
			call %batch_path%log-util.bat info "dns-monitor.bat received max timeout number,ignore this IP and retry automatically"		
		) else (
			set ip=!ping_resp_row[%PING_RESP_IP_ROW_INDEX%]!
			set prefix=!ping_resp_row[%PING_RESP_TOTAL_ROW_NUMBER%]!
			
			if !prefix!==%PING_RESP_LAST_ROW_PREFIX% (
				REM check if current ip is existed in hosts, if yes do nothing, 
				REM echo found ip !ip! for %domain%
				call %batch_path%log-util.bat info "dns-monitor.bat found ip !ip! for %domain%"
				call %batch_path%hosts-update.bat %domain% !ip!
				REM break current loop since we have found the high quanlity IP already
				goto :eof
			) else (
				call %batch_path%log-util.bat debug "dns-monitor.bat ip !ip!, prefix !prefix!"
			)
		)
	) else (
		REM echo current ping failed, will try again. ping_resp_row_number: !ping_resp_row_number!
		call %batch_path%log-util.bat info "dns-monitor.bat current ping failed, will try again. ping_resp_row_number: !ping_resp_row_number!"
	)
)
REM echo ping failed after retry %MAX_RETRY% times
call %batch_path%log-util.bat info "dns-monitor.bat ping failed after retry %MAX_RETRY% times"
call hosts-update.bat %domain%



