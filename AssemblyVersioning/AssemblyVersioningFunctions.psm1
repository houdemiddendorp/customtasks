# function for updating version numbers
function Update-SourceVersion
{
    Param 
    (
        [string]$SrcPath,
        [string]$assemblyVersion, 
        [string]$fileAssemblyVersion
    )

    # determine build incremental number
    $buildNumber = $env:BUILD_BUILDNUMBER
    if ($buildNumber -eq $null)  
    {
        $buildIncrementalNumber = 0
    }
    else
    {
        $splitted = $buildNumber.Split('.')
        $buildIncrementalNumber = $splitted[$splitted.Length - 1]
    }

    if ($fileAssemblyVersion -eq "")
    {
        $fileAssemblyVersion = $assemblyVersion
    }

    # change J and B in version strings to resp. date (yyyymmdd) and build incremental number
    $jdate = Get-Date -Format yyyyMMdd
    $newAssemblyVersion = $assemblyVersion.Replace("J", $jdate).Replace("B", $buildIncrementalNumber)
    $newFileAssemblyVersion = $fileAssemblyVersion.Replace("J", $jdate).Replace("B", $buildIncrementalNumber)


    Write-Host "Executing Update-SourceVersion in path $SrcPath, Version is $assemblyVersion and File Version is $fileAssemblyVersion"
    Write-Host "Transformed Version is $newAssemblyVersion and Transformed File Version is $newFileAssemblyVersion"

    # assemblyinfo versioning
    $AllVersionFiles = Get-ChildItem $SrcPath\* -Include AssemblyInfo.cs,AssemblyInfo.vb -recurse
    foreach ($file in $AllVersionFiles)
    { 
        Write-Host "Modifying file " + $file.FullName
        $backFile = $file.FullName + "._ORI"
        $tempFile = $file.FullName + ".tmp"
        Copy-Item $file.FullName $backFile -Force
        Get-Content $file.FullName |
            %{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyVersion(""$newAssemblyVersion"")" } |
            %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyFileVersion(""$newFileAssemblyVersion"")" }  > $tempFile
        Move-Item $tempFile $file.FullName -Force
    }

    # SQL script versioning
    $AllVersionFiles = Get-ChildItem $SrcPath\* -Include *.sql -recurse
    foreach ($file in $AllVersionFiles)
    { 
        Write-Host "Modifying file " + $file.FullName
        $backFile = $file.FullName + "._ORI"
        $tempFile = $file.FullName + ".tmp"
        Copy-Item $file.FullName $backFile -Force
        Get-Content $file.FullName |
            %{$_ -replace 'declare @versionNr varchar\(50\) = ''[0-9]+(\.([0-9]+|\*)){1,3}''', "declare @versionNr varchar(50) = '$newFileAssemblyVersion'" }  > $tempFile
        Move-Item $tempFile $file.FullName -Force
    }


    # nuget package versioning
    $AllVersionFiles = Get-ChildItem $SrcPath\* -Include *.nuspec -recurse  
    foreach ($file in $AllVersionFiles)
    { 
        Write-Host "Modifying file " + $file.FullName
        $backFile = $file.FullName + "._ORI"
        $tempFile = $file.FullName + ".tmp"
        Copy-Item $file.FullName $backFile -Force
        Get-Content $file.FullName |
            %{$_ -replace '<version>[0-9]+(\.([0-9]+|\*)){1,3}</version>', "<version>$newFileAssemblyVersion</version>" }  > $tempFile
        Move-Item $tempFile $file.FullName -Force
    }

}

# function for restoring changed files
function Restore-SourceVersion
{
    Param 
    (
        [string]$SrcPath
    )

    Write-Host "Executing Restore-SourceVersion in path $SrcPath"

    # assemblyinfo.cs
    $AllVersionFiles = Get-ChildItem $SrcPath\* -Include AssemblyInfo.cs,AssemblyInfo.vb -recurse
    foreach ($file in $AllVersionFiles) 
    { 
        Write-Host "Restoring file " + $file.FullName
   
        $backFile = $file.FullName + "._ORI"
        if ([System.IO.File]::Exists($backFile))
        {
            Move-Item $backFile $file.FullName -force
        }       
    }

    # SQL scripts
    $AllVersionFiles = Get-ChildItem $SrcPath\* -Include *.sql -recurse
    foreach ($file in $AllVersionFiles) 
    { 
        Write-Host "Restoring file " + $file.FullName
   
        $backFile = $file.FullName + "._ORI"
        if ([System.IO.File]::Exists($backFile))
        {
            Move-Item $backFile $file.FullName -force
        }       
    }

    # nuget package definitions
    $AllVersionFiles = Get-ChildItem $SrcPath\* -Include *.nuspec -recurse  
    foreach ($file in $AllVersionFiles) 
    { 
        Write-Host "Restoring file " + $file.FullName
   
        $backFile = $file.FullName + "._ORI"
        if ([System.IO.File]::Exists($backFile))
        {
            Move-Item $backFile $file.FullName -force
        }       
    }
}