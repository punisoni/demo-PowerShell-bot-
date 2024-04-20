param(
    [string]$ServerName,
    [string]$LogFilePath,
    [string]$logEntryBot
)

try {

    # Read the content of the file into a variable

    $content = Get-Content -Path "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\conf\config.ini" -Raw

 

    # Use regular expression to extract the username

    if ($content -match 'username:\s*(\S+)') {

        $username = $matches[1]

        Write-Host "Username:$username"

    } else {

        throw "Username not found in the file."

    }

} catch {

    Write-Host "An error occurred: $_"

}
    

try{
    $encryptedPassword = Get-Content -Path "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\lib\securestring.txt" #| ConvertTo-SecureString
    $plaintextPassword = ConvertTo-SecureString $encryptedPassword

}
catch{
    & $logEntryBot "Error: Unable to retrieve the password from the file." -LogFile $LogFilePath
    exit 1
}

try{
    $SecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($plaintextPassword))
}
catch{
    & $logEntryBot "Unable to convert the password too plain text" -LogFile $LogFilePath
    exit 1
}
# Now, you can use $plaintextPassword to log in to a server
# Replace the placeholders with your actual login code

# Authenticate to server
try{
        $server = $ServerName
        #$username = "test\Administrator"
        $password = $SecurePassword

        $secpass = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ($username, $secpass)

        # Connect to the server
        $session = New-PSSession -ComputerName $server -Credential $credential

         
        $sessionID = $session.Id
        $sessionID | out-file -FilePath "C:\CREATE_Automation\CREATE2023-4800_Remote_Utilities_Access\conf\sessionid.txt"

        Write-Output "Authentication Successful for $Servername"
        

        #Checking PS session Info 
        #$NewID = $PSSessionId
        #Write-Host "the current session id is : $NewID"

        #$session = New-PSSession -ComputerName EC2AMAZ-6P6HDMD -Credential $credential
        $sessionInfo = [PSCustomObject]@{
            Session = $session
            SessionID = $session.Id
           }
           #Write-Host "The session info Gave : $sessionInfo"

        $sessionInfo
    }

catch {
    Write-Output "Authentication failed for $Servername"
     & $logEntryBot "Authentication failed for $Servername" -LogFile $LogFilePath
    exit 1
}



