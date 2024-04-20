param(
    [string]$serverName,
    [string]$groupName,
    [string]$userToRemove,
    [string]$logFile,
    [string]$LogEntryBot

) 

try {
    # Use the Active Directory module
    #Import-Module ActiveDirectory

    # Check if the group exists
    if (Get-ADGroup -Filter {Name -eq $groupName}) {
        # Check if the user is a member of the group
        if (Get-ADGroupMember -Identity $groupName -Recursive | Where-Object {$_.SamAccountName -eq $userToRemove}) {
            # Remove the user from the group

            Remove-ADGroupMember -Identity $groupName -Members $userToRemove -Server $serverName -Confirm:$false
            # Log success to the log file
             & $LogEntryBot "Successful" -LogFile $logFile
            & $LogEntryBot "User $userToRemove successfully removed from group $groupName on server $serverName" -LogFile $logFile #| Out-File -Append -FilePath $logFilePath
             Write-Output "User $userToRemove successfully removed from group $groupName on server $serverName"
        }

        else {
            # Log failure (user not found in the group) to the log file
            & $LogEntryBot "Failure" -LogFile $logFile
            & $LogEntryBot "User $userToRemove is not a member of group $groupName on server $serverName" -LogFile $logFile #| Out-File -Append -FilePath $logFilePath
            Write-Output "User $userToRemove is not a member of group $groupName on server $serverName"

        }

    }

    else {
        # Log failure (group not found) to the log file
        & $LogEntryBot "Failure" -LogFile $logFile
        & $LogEntryBot "Group $groupName does not exist on server $serverName" -LogFile $logFile # | Out-File -Append -FilePath $logFilePath
        Write-Output "Group $groupName does not exist on server $serverName"
    }

}

catch {
    # Log any errors to the log file
    & $LogEntryBot "Error" -LogFile $logFile
    & $LogEntryBot "Error: $_" -LogFile $logFile #| Out-File -Append -FilePath $logFilePath
}