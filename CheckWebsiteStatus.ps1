 <#
Purpose: To check the status of a webiste and report back if status is not 200
Syntax: CheckWebsiteStatus.ps1 -URLListFile "C:\ProgramData\OpConxps\URLList.txt" -URLResultsFile "C:\ProgramData\OpConxps\URLResults.txt"
Exit Code: 30 = Unable to reach where URLListFile is saved at
Exit Code 8754 = A Webite(s) is not returing a status code of 200
Tested on 04/27/20
Written By David Cornelius
#>
param (
    [parameter(mandatory=$true)]
    [string]$URLListFile,
    [parameter(mandatory=$true)]
    [string]$URLResultsFile
      )
$ErrorActionPreference = "Stop"
#Check to see if we can reach the path to our URL List File
If (!(Test-Path $URLListFile))
    {
        $rc = 30
        Write-output [$(Get-Date)]:"Unable to access $fileToCheck -RC =$rc"
        Exit $rc
    }
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue
#For every URL in the list
Foreach($Uri in $URLList) {
    try{
        #For proxy systems
        [System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebRequest]::GetSystemWebProxy()
        [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        #Web request
        $req = [system.Net.WebRequest]::Create($uri)
        $res = $req.GetResponse()
    }catch {
        #Err handling
        $res = $_.Exception.Response
    }
    $req = $null
    #Getting HTTP status code
    $int = [int]$res.StatusCode
    #Writing to a file for processing
    "$int - $uri" | Out-File $URLResultsFile -Append -Encoding string
    #Writing on the screen
    Write-Host  "$int - $uri"
  
    #Disposing response if available
    if($res){
        $res.Dispose()
    }
}
 
    #See if any sites return a result other than 200
    $No200 = Get-Content $URLResultsFile | Select-String -NotMatch "200"
 if( $No200 -eq $null)
    {
         Write-Output [$(Get-Date)]:"All Sites returned a status code of 200"
         Write-Output [$(Get-Date)]:"Valdation has finnished"
      
    }
 
Else
    {
        $rc = 8754
        Write-Output [$(Get-Date)]:"The below site(s) did not return a code of 200"
        Write-Output [$(Get-Date)]:"$No200"
        Write-Output [$(Get-Date)]:"Valdation has finnished"
        Exit $rc
    }


