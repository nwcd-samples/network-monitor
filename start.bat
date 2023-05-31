@rem Create a Windows system scheduler to check network status to access Amazon related sites
@rem We use PING action to check network issue, as we known, PING will repeat 4 times by default
@rem If timeout response reaches 3 times, will skip it and retry next IP for the domain names

@echo off

rem create Windows system scheduler to check DNS status
set batch_home=%~dp0
set task_name=%1

REM echo workinging dircgtory is %batch_home% >> C:\Users\Administrator\Documents\log.txt
REM exit /b 0
REM call %batch_home%log-util.bak info "scheduler task %task_name% created successfully."

if "%task_name%"=="" set task_name=amaz-sites-accelerator
rem check if service is existed
schtasks /query /tn %task_name%
if not %errorlevel% equ 0 (
	rem schtasks /create /tn %task_name% /tr %batch_home%dns-monitor.bat >> %batch_home%log.txt /sc minute /mo 10
	schtasks /create /tn %task_name% /tr %batch_home%echo-hello-world.bat >> %batch_home%log.txt /sc minute /mo 2
	call %batch_home%log-util.bak info "scheduler task %task_name% created successfully."
) else (
	call %batch_home%log-util.bak error "scheduler task %task_name% existed, please change another one"
)