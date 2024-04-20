<#Write-host " << This Bot is capable to add and remove members from AD groups >>"
$Action = Read-host "Please select Add or Remove: "
$user_ID = Read-host "Please enter the user name: "
$AD_group_name = Read-host "Please enter the group name: "
#$Server_name = "EC2AMAZ-6P6HDMD"
$request_number = Read-Host "please enter request number:   "

#>
# Define the file path
$filePath = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\conf\Input.txt"
$LogEntryBot = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\Scripts\MicroBots\Logentrybot.exe"
 

try {
    # Prompt the user for inputs
    $Action = Read-Host "Please enter Action (Add/Remove): "
    $user_ID = Read-Host "Please enter User ID: "
    $AD_group_name = Read-Host "Please enter AD Group Name: "
    #$Server_name = Read-Host "Please enter Server Name: "
    $request_number = Read-Host "Please enter Request Number: "
    $logFileName = "${request_number}.txt"
    $LogFilePath = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\log\$logFileName"
    

    Write-Host "$env:USERNAME is executing current script"
    & $LogEntryBot "$env:USERNAME is executing current script" -LogFile $LogFilePath


    # Format the inputs and write to the file
    $inputContent = @"
    Action: $Action
    User ID: $user_ID
    AD Group Name: $AD_group_name
    request Number: $request_number
    LogFilePath: $LogFilePath
"@

 

    # Write the formatted input to the file
    $inputContent | Set-Content -Path $filePath -Force

 

    Write-Host "Inputs have been saved to $filePath."
    & $LogEntryBot "Inputs have been saved to $filePath." -LogFile $LogFilePath
  

    $counter = 1
    #$scriptPath = "C:\Users\Administrator\Desktop\4800_Sunday-15-10-2023-Copy\Scripts\MicroBots\Main_Bot1.exe"
#$scriptPath = & $MasterBot -Action $Action -AD_group_name $AD_group_name -user_ID $User_ID -request_number $request_number

while ($counter -le 2) {

    # Set the time limit for script execution (in seconds)

    $timeLimit = 45 
    & $LogEntryBot "Maximum allowed time for the script: $timeLimit seconds" -LogFile $LogFilePath

    # Start the script as a background job

    $job = Start-Job -ScriptBlock {
        $scriptPath = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\Scripts\MicroBots\Main_Logic_Bot.exe" 
        #param($scriptPath)

        Invoke-Expression -Command $scriptPath #-ArgumentList $Action,$AD_group_name,$user_ID,$request_number
        #& $scriptPath -Action $Action -AD_group_name $AD_group_name -User_ID $user_ID -request_number $request_number

    } #-ArgumentList $scriptPath


    try {

        # Wait for the job to finish or timeout


     $jobwait = Wait-Job -Job $job -Timeout $timeLimit
     $timeTaken = $jobwait.PSEndTime - $jobwait.PSBeginTime
     <#$jobwait | ForEach-Object { 
            $timeTaken = $_.PSEndTime - $_.PSBeginTime
            $_ | Select-Object PSBeginTime, PSEndTime, @{Name="TimeTaken"; Expression={$timeTaken}}

        }#> 

        



        if ($jobwait) {


            # Job completed within the time limit


            $output = Receive-Job -Job $job

            & $LogEntryBot "Script executed successfully in $timeTaken (seconds)" -LogFile $LogFilePath

           # Write-Host "Script executed successfully in $timeTaken (seconds)"
            break

        } else {

 
            # Job timed out

            Write-Host "Script execution timed out or is not responding."
            & $LogEntryBot "Script execution timed out or is not responding." -LogFile $LogFilePath

            # If this is the first timeout, increment the counter and retry


            if ($counter -eq 1) {

 
                $counter++
 

                Write-Host "Retrying script execution (Attempt $counter)..."
                & $LogEntryBot "Retrying script execution (Attempt $counter)..." -LogFile $LogFilePath
 

           } else {

 
                # This is the second timeout, terminate the script


                Write-Host "Script execution failed after retrying for attempt: $counter."
                & $LogEntryBot "Script execution failed after retrying for attempt: $counter." -LogFile $LogFilePath


                break

            } 

        }


   } catch {

 

        # Handle any errors or exceptions here


        Write-Host "An error occurred: $_"
        & $LogEntryBot "An error occurred: $_" -LogFile $LogFilePath

        }
        finally {

 

        # Stop and remove the job

 

        if ($job.State -eq "Running") {

 

            Stop-Job -Job $job

 

        }

 

        Remove-Job -Job $job

 

    }

 

}



 

} catch {
    Write-Host "An error occurred: $_"
    & $LogEntryBot "An error occurred: $_" -LogFile $LogFilePath
}

