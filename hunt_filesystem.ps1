#Applocker Bypass Check for Windows Folder Structure
# based on someone's existing routine that i now can't find so thanks to original author. I've modded this a lil. i honestly think I'd do this differently from scratch, probably with a report generated at the end, who knows!
# use at own risk blah blah blah
write-host "########################################################" -ForegroundColor Yellow
write-host "Applocker Folder Hunter" -ForegroundColor Yellow
write-host "########################################################" -ForegroundColor Yellow

$start = Get-Date

$start


$lockerpol = Get-AppLockerPolicy -Effective -Verbose
$profile = $env:USERPROFILE

foreach($policy in $lockerpol){
write-host $policy.RuleCollectionTypes

}

if($policy.RuleCollectionTypes -contains "exe"){
write-host "Applocker Executable policy in effect" -ForegroundColor Red

$policy.RuleCollections
}
write-host "########################################################" -ForegroundColor Gray
write-host "Hunting for Applocker bypasses" -ForegroundColor Cyan
write-host "########################################################" -ForegroundColor Gray

Get-ChildItem C:\ -Filter cmd1.exe -Recurse -ErrorAction SilentlyContinue -Exclude $profile | Remove-Item -ErrorAction SilentlyContinue

foreach($_ in (Get-ChildItem C:\ -recurse -ErrorAction SilentlyContinue)){
    if($_.PSIsContainer)
    {
        Set-Location $_.FullName
        try{Copy-Item "C:\Windows\System32\cmd.exe" .\cmd1.exe -ErrorAction SilentlyContinue}catch{write-host "Error creating File" -foregroundcolor red}
        
        if (Test-Path -Path .\cmd1.exe)
            {
            Write-Host "Trying to execute in writable folder" $_.FullName -ForegroundColor Yellow
            try{
            Start-Process .\cmd1.exe -WindowStyle Hidden
                      
            }catch{write-host "Error Launching File" -foregroundcolor red}
            Stop-Process -name "cmd1" -ErrorAction SilentlyContinue
            }
    }
}

Write-Host "The following paths allow write access" -ForegroundColor Green
Get-ChildItem C:\ -Filter cmd1.exe -Recurse -ErrorAction SilentlyContinue | Select-Object FullName | Format-Table -AutoSize

Write-Host "The following paths allow write access and we can execute" -ForegroundColor Green
try{(Get-Process notepad -ErrorAction SilentlyContinue).MainModule | select FileName -ErrorAction SilentlyContinue}catch{write-host "no locations found" -ForegroundColor Green}

write-host "Hunting for test processes.... cmd1.exe" -ForegroundColor Gray 
try{get-process -name notepad1 -ErrorAction Stop
try{Stop-Process -Name notepad1 -Force -ErrorAction SilentlyContinue}catch{write-host "No test process found to kill" -ForegroundColor Red}
}catch{write-host "no process found" -ForegroundColor Red}


write-host "Clearing up any istances of cmd1.exe......" -ForegroundColor Gray 
#Clear up the files
try{Get-ChildItem C:\ -Filter cmd1.exe -Recurse -ErrorAction SilentlyContinue |  Remove-Item -Force -ErrorAction SilentlyContinue}catch{write-host "Error when cleaning up!!!!" -ForegroundColor Red}

$end = Get-Date

$end

write-host "########################################################" -ForegroundColor Yellow
write-host "End of Applocker Folder Hunter" -ForegroundColor Yellow
write-host "########################################################" -ForegroundColor Yellow
