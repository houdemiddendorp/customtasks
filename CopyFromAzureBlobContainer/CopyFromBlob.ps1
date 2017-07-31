$ConnectedServiceNameSelector = Get-VstsInput -Name ConnectedServiceNameSelector
$ConnectedServiceName = Get-VstsInput -Name ConnectedServiceName
$ConnectedServiceNameARM = Get-VstsInput -Name ConnectedServiceNameARM
$StorageAccountName = Get-VstsInput -Name StorageAccountName
$StorageAccount = Get-VstsInput -Name StorageAccount
$StorageAccountRM = Get-VstsInput -Name StorageAccountRM
$ContainerName = Get-VstsInput -Name ContainerName
$FileName = Get-VstsInput -Name FileName
$DestinationFolder = Get-VstsInput -Name DestinationFolder

Write-Host "ConnectedServiceNameSelector = $ConnectedServiceNameSelector"
Write-Host "ConnectedServiceName = $ConnectedServiceName"
Write-Host "ConnectedServiceNameARM = $ConnectedServiceNameARM"
Write-Host "StorageAccountName = $StorageAccountName"
Write-Host "StorageAccount = $StorageAccount"
Write-Host "StorageAccountRM = $StorageAccountRM"
Write-Host "ContainerName = $ContainerName"
Write-Host "FileName = $FileName"
Write-Host "DestinationFolder = $DestinationFolder"



if ($ConnectedServiceNameSelector -eq "Anonymous")
{
    $storageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -Anonymous
}

if ($ConnectedServiceNameSelector -eq "ConnectedServiceName")
{
    # Import Azure Helpers
    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Initialize-Azure

    # load Utility
    . "$PSScriptRoot\Utility.ps1"

    # Load correct Azure Utility version
    $azureUtility = Get-AzureUtility $ConnectedServiceName
    . "$PSScriptRoot/$azureUtility"

    # create storage context
    $connectionType = Get-TypeOfConnection -connectedServiceName $ConnectedServiceName
    $storageKey = Get-StorageKey -storageAccountName $StorageAccount -connectionType $connectionType -connectedServiceName $ConnectedServiceName
    $storageContext = Create-AzureStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $storageKey
}

if ($ConnectedServiceNameSelector -eq "ConnectedServiceNameARM")
{
    # Import Azure Helpers
    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Initialize-Azure

    # load Utility
    . "$PSScriptRoot\Utility.ps1"

    # Load correct Azure Utility version
    $azureUtility = Get-AzureUtility $ConnectedServiceNameARM
    . "$PSScriptRoot/$azureUtility"

    # create storage context
    $connectionType = Get-TypeOfConnection -connectedServiceName $ConnectedServiceNameARM
    $storageKey = Get-StorageKey -storageAccountName $StorageAccountRM -connectionType $connectionType -connectedServiceName $ConnectedServiceNameARM
    $storageContext = Create-AzureStorageContext -StorageAccountName $StorageAccountRM -StorageAccountKey $storageKey
}

Write-Host "Download files ..."
$blobs = Get-AzureStorageBlob -Context $storageContext -Container $ContainerName -Blob $FileName | Get-AzureStorageBlobContent –Destination $DestinationFolder -Verbose
Write-Host "Ready"
