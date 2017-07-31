param (
    [string]$runOnAgent,
    [string]$computerName,
    [string]$credentialUserName,
    [string]$credentialPassword,
    [string]$serverName,
    [string]$databaseName,
    [string]$useSQLAuthentication,
    [string]$userName,
    [string]$password,
    [string]$scriptName
)

[bool]$roa = $false
if ($runOnAgent.ToLower() -eq "true") { $roa = $true } else { $roa = $false }

[bool]$usa = $false
if ($useSQLAuthentication.ToLower() -eq "true") { $usa = $true } else { $usa = $false }

Write-Host "serverName = $serverName"
Write-Host "databaseName = $databaseName"

if ($usa -eq $true)
{
    Write-Host "userName = $userName"
    Write-Host "password = $password"
}
Write-Host "scriptName = $scriptName"
Write-Host "run on agent = $roa"
Write-Host "use SQL auth = $usa"

if ($roa -eq $false)
{
    $pass = ConvertTo-SecureString -AsPlainText $credentialPassword -Force
    $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $credentialUserName, $pass
    Write-Host "Entering RunSqlScript.ps1 on $computerName"
}

if ($usa -eq $true)
{
    if ($roa -eq $true)
    {
        Write-Host "Run on agent"
        . sqlcmd -S $serverName -d $databaseName -U $userName -P $password -i $scriptName
    }
    else
    {
        $scriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock(". sqlcmd -S $serverName -d $databaseName -U $userName -P $password ")
        Write-Host $scriptBlock.ToString()
        Get-Content $scriptName | Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $scriptBlock
    }
}
else
{
    if ($roa -eq $true)
    {
        Write-Host "Run on agent"
        . sqlcmd -S $serverName -d $databaseName -i $scriptName
    }
    else
    {
        $scriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock(". sqlcmd -S $serverName -d $databaseName ")
        Write-Host $scriptBlock.ToString()
        Get-Content $scriptName | Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $scriptBlock
    }
}


Write-Host "Ready"
