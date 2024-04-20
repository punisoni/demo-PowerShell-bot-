param(
    [string]$serverName,
    [string]$groupName,
    [string]$userToAdd,
    [string]$logFilePath,
    [string]$logEntryBot
)

try {
    # Use the Active Directory module
    #Import-Module ActiveDirectory

    # Check if the group exists
    if (Get-ADGroup -Filter {Name -eq $groupName}) {
        # Add the user to the group
        Add-ADGroupMember -Identity $groupName -Members $userToAdd -Server $serverName
        # Log success to the log file
        & $LogEntryBot "Successful" -LogFile $logFilePath
        & $logEntryBot "User $userToAdd successfully added to group $groupName on server $serverName" -LogFile $logFilePath #| Out-File -Append -FilePath $logFilePath
        Write-Output "User $userToAdd successfully added to group $groupName on server $serverName !"
    }

    else {
        # Log failure to the log file
        & $LogEntryBot "Failure" -LogFile $logFilePath
        & $logEntryBot "Group $groupName does not exist on server $serverName" -LogFile $logFilePath #| Out-File -Append -FilePath $logFilePath
        Write-Output "Group $groupName does not exist on server $serverName"
    }

}

catch {
    # Log any errors to the log file
    & $LogEntryBot "Error" -LogFile $logFilePath
    & $logEntryBot "Error: $_" -LogFile $logFilePath #| Out-File -Append -FilePath $logFilePath
}