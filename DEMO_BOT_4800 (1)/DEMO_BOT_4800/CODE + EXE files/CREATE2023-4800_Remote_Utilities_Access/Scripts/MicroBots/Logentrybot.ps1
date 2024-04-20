param ([string]$LogMessage, [string]$LogFile)

#$CsvFolder = ""  #Specify the folder where CSV files are located

#pull the latest CSV file in the folder 
#$LatestCsvFile = Get-ChildItem -Path $CsvFolder -Filter "*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
#if ($LatestCsvFile){
   #load the request number from the latest log file
    #$CsvData = Import-Csv -Path $LatestCsvFile.FullName   
    #$request_number = $CsvData.$request_number
    try {
      $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"    #adding time stamp
      $LogEntry = "$TimeStamp - $LogMessage"  
      Add-Content -Path $LogFile -Value $LogEntry   #Adding an entry to the main log file
    }
    catch {

    Write-Error "Error occurred while writing to the log file: $_"
    #Add-Content -Path $LogFile -Value "Error occurred while writing to the log file: $_"

    }


<#
else {
    Write-Host "No CSV Files found in the specified folder"
}#>