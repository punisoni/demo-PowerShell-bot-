<#Write-host " << This Bot is capable to add and remove members from AD groups >>"
$Action = "Remove" #Read-host "Please select Add or Remove: "
$user_ID = "ampkst" #Read-host "Please enter the user name: "
$AD_group_name = "itadmingroup1" #Read-host "Please enter the group name: "
$Server_name = "EC2AMAZ-6P6HDMD"
$request_number = "SRW00789789" #Read-Host "please enter request number:  
#>

# Defining paths


$inputFilePath = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\conf\Input.txt"
#$Server_name = "EC2AMAZ-OJ9690C"

try {

    # Read the content of the file into a variable

    $content = Get-Content -Path "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\conf\config.ini" -Raw

 

    # Use regular expression to extract the username

    if ($content -match 'servername:\s*(\S+)') {

        $Server_name = $matches[1]

       

    } else { Write-Output "ServerName:$Server_name"

        throw "ServerName not found in the file."

    }

} catch {

    Write-Host "An error occurred: $_"

}

#calling Session ID



# Calling Micro bots using variable 

$AddUser = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\Scripts\MicroBots\Windows_AD_addUser.exe"
$RemoveUser = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\Scripts\MicroBots\Windows_AD_removeUser.exe"
$LogEntryBot = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\Scripts\MicroBots\Logentrybot.exe"
$Connect_Auth = "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\Scripts\MicroBots\Connect_Auth.exe"

<#param (
    [string]$Action,     # 'Add' or 'Remove'
    #[string]$Server_name,
    [string]$AD_group_name,
    [string]$User_ID,
    [string]$request_number
)#>

$VerbosePreference = "Continue"    # Enable verbose and debug output
$DebugPreference = "Continue"      # optional

try {
    # Check if the input file exists
    if (Test-Path $inputFilePath -PathType Leaf) {
        # Read the content of the file
        $fileContent = Get-Content $inputFilePath

 

        # Initialize variables
        $Action = ""
        $user_ID = ""
        $AD_group_name = ""
       # $Server_name = ""
        $request_number = ""
        $LogFilePath = ""

 

        # Parse the file content and assign values to variables
        $newFileContent = @()
        $replaceContent = $false

 

        $fileContent | ForEach-Object {
            $line = $_.Trim()
            if ($line -match "Action:\s*(.+)") {
                $Action = $matches[1].Trim()
                $replaceContent = $true
            } elseif ($line -match "User ID:\s*(.+)") {
                $user_ID = $matches[1].Trim()
            } elseif ($line -match "AD Group Name:\s*(.+)") {
                $AD_group_name = $matches[1].Trim()
            } ##elseif ($line -match "Server Name:\s*(.+)") {
                #$Server_name = $matches[1].Trim() }
             elseif ($line -match "Request Number:\s*(.+)") {
                $request_number = $matches[1].Trim()
            } elseif ($line -match "LogFilePath:\s*(.+)") {
                $LogFilePath = $matches[1].Trim()
                }

 

            if ($replaceContent) {
                # Replace the line with just the label (e.g., "Action: ")
                $newFileContent += "$($line -replace ':\s*.+$', ': ')"
                $replaceContent = $false
            }
        }

 

        # Output to verify the values read from the file
        <#Write-Output "Action: $Action"
        Write-Output "User ID: $user_ID"
        Write-Output "AD Group Name: $AD_group_name"
        Write-Output "Server Name: $Server_name"
        Write-Output "Request Number: $request_number"
        Write-Output "$LogFilePath"#>
 

        # Overwrite the input file with modified content
        #$newFileContent | Set-Content -Path $inputFilePath -Force
        Clear-Content -Path $inputFilePath
        & $LogEntryBot "Input file is cleared after reading inputs" -LogFile $LogFilePath


#$request_number = "SR0002342"
#$currentDate = Get-Date -Format "yyyy-MM-dd HH;mm;ss"
#$logFileName = "${request_number}.txt"
#$LogFilePath = "C:\Users\Administrator\Desktop\Latest\New_12-10-2023_Copy\4800_New\Logs\$logFileName"

# Calling bot using variable




#Clear-Host
#import-module ActiveDirectory



    # Perform the job in MasterBot 
    
    # $Windows_AD_adduser = "C:\Users\adarun\OneDrive - Capgemini\Documents\Developers_Automation_POD\Design DOCS\4800\Windows_AD_user_PS\Script\MicroBots\Windows_AD_addUser.ps1"
    # Print connection of the server status.....
        if (Test-Connection -ComputerName $Server_name -Count 1 -Quiet){

                Write-Output "Server: $Server_name is reachable, Hence proceeding for Authentication"
                & $LogEntryBot "Server: $Server_name is reachable, Hence proceeding for Authentication " -LogFile $LogFilePath

                $sessionInfo = & $Connect_Auth -serverName $Server_name -LogFile $LogFilePath -LogEntryBot $LogEntryBot

            # Check if Authentication is successful
            if ($null -ne $sessionInfo){
                 #$session = $sessionInfo.Session
                $session_id = $sessionInfo.SessionID

                $session_id = Get-Content -Path "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\conf\sessionid.txt"
                Remove-Item -Path "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\conf\sessionid.txt"

                Write-Output "Authentication is successful on the server $Server_name"
                & $LogEntryBot "Authentication is successful on the server $Server_name" -LogFile $LogFilePath

                try {
                    & $LogEntryBot "Execution started for User: $User_ID with session-ID: $session_id" -LogFile $LogFilePath     # Call the "Logs" microBot to start logging

                    # Check if the server is online
                    if (Test-Connection -ComputerName $Server_name -Count 1 -Quiet) {
                 
               
                    # Connect to the specified AD server
                    $Server = Get-ADDomainController -Server $Server_name

                    # Check if the user is a member of the specified AD group                   
                    $isMember = Get-ADGroupMember -Server $Server.Name $AD_group_name | Where-Object { $_.SamAccountName -eq $User_ID }

                    if ($isMember -and $Action -eq 'Remove') {

                        & $LogEntryBot "Remove bot is in execution for: $User_ID with session-ID: $session_id" -LogFile $LogFilePath
                        ## TRIGGER REMOVE BOT
                        & $RemoveUser -serverName $Server_name -groupName $AD_group_name -userToRemove $User_ID -LogFile $LogFilePath -LogEntryBot $LogEntryBot
            
                        # Call the "Logs" microBot to log the success
                        #& $LogEntryBot "MicroBot1 - User $User_ID is a member of $AD_group_name on server $Server_name."
                    }
                    elseif ($isMember -and $Action -eq 'Add') {
                        & $LogEntryBot "Already-Member" -LogFile $LogFilePath
                        & $LogEntryBot "MicroBot1 - User $User_ID is already a member of $AD_group_name on server $Server_name No action needed !!" -LogFile $LogFilePath
                        ## Simply break and write the log that user is already the member of the group
                        Write-Output "MicroBot1 - User $User_ID is already a member of $AD_group_name on server $Server_name No action needed !!"
                    }

                    elseif($Action -eq 'Add') {
                        & $LogEntryBot "Add bot is in execution for: $User_ID with session-ID: $session_id" -LogFile $LogFilePath
                        ## Trigger the ADD Microbot
                        & $AddUser  -serverName $Server_name -groupName $AD_group_name -userToAdd $User_ID -LogFile $LogFilePath -LogEntryBot $LogEntryBot
                        # Call the "Log" microBot to log the failure
                        #& $LogEntryBot "MicroBot1 - User $User_ID is not a member of $AD_group_name on server $Server_name."
                    }
            }              
        else {
                & $LogEntryBot "MicroBot1 - Server $Server_name is not online. Exiting script" -LogFile $LogFilePath
            }
        }
                catch {
        & $LogEntryBot "An error occurred while checking group membership: $_" -LogFile $LogFilePath
    }
                #Disconnect-PSSession -Id $session_id
                #Write-Host "$session_id  Disconnected"  
                #& $LogEntryBot " PS Session Disconnected" -LogFile $LogFilePath
}
            else  {
                & $LogEntryBot "An error occurred while checking group membership: $_" -LogFile $LogFilePath
}
}

        else {
        Write-Output "Server: $Server_name is not reachable"
        & $LogEntryBot "Server: $Server_name is not reachable" -LogFile $LogFilePath

}
}
else {
        Write-Output "Input file not found: $inputFilePath"
        & $LogEntryBot "Input file not found: $inputFilePath" -LogFile $LogFilePath
    }
} catch {
    Write-Output "An error occurred while reading the input file or processing the content: $_"
    & $LogEntryBot "An error occurred while reading the input file or processing the content: $_" -LogFile $LogFilePath
}