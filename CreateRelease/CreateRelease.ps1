Param(
   [string]$ConnectionTypeSelector,
   [string]$vstsAccount,
   [string]$TFSUri,
   [string]$personalAccessToken,
   [string]$projectName,
   [string]$releaseDefinitionName,
   [string]$releaseDescription
)

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $personalAccessToken)))

# Construct the REST URL to obtain list of releases
if ($ConnectionTypeSelector -eq "VSTSConnection")
{
    $uri = "https://$($vstsAccount).vsrm.visualstudio.com/DefaultCollection/$($projectName)/_apis/release/definitions?api-version=3.0-preview.2"
}
else
{
    $uri = "$($TFSUri)/$($projectName)/_apis/release/definitions?api-version=3.0-preview.2"
}

# Invoke the REST call and capture the results
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$releaseFound = 0
if ($result.count -ne 0)
{
    for($i = 0; $i -lt $result.count; $i++)
    {
        if ($result.value[$i].name -eq $releaseDefinitionName)
        {
            # start release
            $releaseID = $result.value[$i].id
            $releaseFound = 1
            Write-Host "Found release $releaseID, now start it ..."

            $body = '{
                "definitionId": ' + $releaseID + ',
                "description": "' + $releaseDescription + '"
            }'

            if ($ConnectionTypeSelector -eq "VSTSConnection")
            {
                $uri = "https://$($vstsAccount).vsrm.visualstudio.com/DefaultCollection/$($projectName)/_apis/release/releases?api-version=3.0-preview.2"
            }
            else
            {
                $uri = "$($TFSUri)/$($projectName)/_apis/release/releases?api-version=3.0-preview.2"
            }
            $releaseresponse = Invoke-RestMethod -Method Post -ContentType application/json -Uri $Uri -Headers @{Authorization=("Basic {0}" -f $base64authinfo)} -Body $body

            Write-Host "Release started, id = $releaseresponse.id"

        }
    }
}

if ($releaseFound -ne 1)
{
    if ($ConnectionTypeSelector -eq "VSTSConnection")
    {
        Write-Error "Release $releaseDefinitionName was not found in project $projectName on $vstsAccount.visualstudio.com"
    }
    else
    {
        Write-Error "Release $releaseDefinitionName was not found in project $projectName on $TFSUri"
    }
}