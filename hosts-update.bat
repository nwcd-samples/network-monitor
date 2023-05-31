@REM Update hosts file
@REM This file receives two parameters, the first is domain name, the second is ip. ip is optional
@REM If ip is empty, which means PING failed, remove domain if existed in Windows hosts file
@REM If ip is not empty, which means PING succeeded, add domain if not existed in Windows hosts file
@echo off

SetLocal enabledelayedexpansion

set /A row_index=0
set domain_name=%~1
set ip=%~2
set windows_host_file=C:\Windows\System32\drivers\etc\hosts
set windows_host_backup=C:\Windows\System32\drivers\etc\hosts_amz_dns.bak
set batch_path=%~dp0

if "%domain_name%"=="" (
	rem echo please specify domain name as the first argument
	call %batch_path%log-util.bat error "hosts-update.bat please specify domain name as the first argument"
	exit /b 0 )

rem echo begin to update hosts for domain name %domain_name% and ip %ip%
call %batch_path%log-util.bat debug "hosts-update.bat begin to update hosts for domain name %domain_name% and ip %ip%"

if exist %windows_host_file% (
    REM find ip of current domain name by PING 
	set /A domain_found=-1
	set /A row_index=0
	for /f "delims=" %%i in (%windows_host_file%) do (
		REM ignore hosts[0], since we'd like to keep hosts line number and hosts index as same all time
		set /A row_index+=1
		set hosts[!row_index!]=%%i
		REM search domain name from Windows hosts lines, say there is line like this: 1.2.3.4 sellercentral.amazon.com
		REM and we'd like to check if sellercentral.amazon.com is existd or not with findstr command
		REM since it exists, then 'echo %%i ^| findstr /i %domain_name%' will get: 1.2.3.4  sellercentral.amazon.com 
		REM so %%o is 1.2.3.4 sellercentral.amazon.com, since we just wanna get domain name part
		REM then adding "tokens=2 delims= " parameters, it means we split 1.2.3.4 sellercentral.amazon.com by space (delims= )
		REM and we just need domain name,it's in the second part, then add tokens=2
		for /f "tokens=2 delims= " %%o in ('echo %%i ^| findstr /i %domain_name%') do set match=%%o
		REM REM found current domain name on Windows hosts file
		REM echo m !match!
		REM record this index of current domain, since we need it later
		if /i "!match!"=="%domain_name%" set /A domain_found=!row_index!
		
		
		
		REM echo found internal !found!
		REM echo %%i
	)
	rem echo original hosts rows !row_index!, domain_found !domain_found!
	call %batch_path%log-util.bat debug "hosts-update.bat original hosts rows !row_index!, domain_found !domain_found!"
	REM domain name is not found in hosts file
	if !domain_found! equ -1 (
		rem echo %domain_name% is not found in hosts file. domain_found: !domain_found!
		call %batch_path%log-util.bat debug "%domain_name% is not found in hosts file. domain_found: !domain_found!"
		if not "%ip%"=="" (
			REM since current domain is not in hosts, but ip found, let append it to hosts file
			rem echo %domain_name% is not in hosts, but ip %ip% found by PING, appending it to hosts file
			call %batch_path%log-util.bat info "hosts-update.bat %domain_name% is not in hosts, but ip %ip% found by PING, appending it to hosts file"
			set /A row_index+=1
			set hosts[!row_index!]=%ip% %domain_name%
			REM backup hosts file first
			REM echo backuping hosts file
			REM if exist %windows_host_backup% del %windows_host_backup%
			 
			type nul > %windows_host_file%
			for /l  %%i in (1,1,!row_index!) do echo !hosts[%%i]! >> %windows_host_file%
			call %batch_path%log-util.bat info "hosts-update.bat hosts file update successfully for domian %domain_name%"
		)
	) else (
		rem  echo %domain_name% found in hosts file. domain_found: !domain_found!
		call %batch_path%log-util.bat info "hosts-update.bat %domain_name% found in hosts file. domain_found: !domain_found!"
		REM domain found in hosts file, but ip not found
		REM which indicates current domain setting is invalid, let's remove this item from hosts file
		if "%ip%"=="" (
			REM remove this domain setting from hosts, since it caused ping failed
			set hosts[!domain_found!]=# REMOVE
			REM echo backuping hosts file
			REM if exist %windows_host_backup% del %windows_host_backup%
			REM move %windows_host_file% %windows_host_backup%
			rem echo clear hosts file , don't worry we have keep its content to hosts variable already 
			type nul > %windows_host_file%
			REM set /A tmp_end=!domain_found!-1
			REM if !tmp_end! lss 1 set /A tmp_end=1
			REM set /A tmp_start=!domain_found!+1
			REM if !tmp_start! gtr !row_index! set /A tmp_start=!row_index!
			REM rem echo tmp_end: !tmp_end!, tmp_start !tmp_start!
			REM call %batch_path%log-util.bat debug "hosts-update.bat tmp_end: !tmp_end!, tmp_start !tmp_start!"
			REM for /l  %%i in (1,1,!tmp_end!) do echo !hosts[%%i]! >> %windows_host_file%
			REM for /l  %%i in (!tmp_start!,1,!row_index!) do echo !hosts[%%i]! >> %windows_host_file%
			for /l %%i in (0,1, !row_index!) do if not "!hosts[%%i]!"=="# REMOVE" (echo !hosts[%%i]! >> %windows_host_file%)
			call %batch_path%log-util.bat info "hosts-update.bat hosts file update successfully for domian %domain_name%"
		)
	)
) else (
	REM could't not find Windows hosts file, let's create it
	REM for /F "tokens=2" %%i in ('date /t') do set mydate=%%i
	REM set mytime=%time%
	echo # Created by DNS Improvement Progress Automatically > %windows_host_file%
	call %batch_path%log-util.bat error "hosts-update.bat hosts file not found, renewed one"
)
endlocal
