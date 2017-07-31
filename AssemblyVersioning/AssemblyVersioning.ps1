Param
(
    [string] $srcPath,
    [string] $assemblyVersion,
    [string] $fileAssemblyVersion
)

Write-Output "SrcPath = $srcPath AssemblyVersion = $assemblyVersion FileAssemblyVersion = $fileAssemblyVersion"

if(-not(Get-Module -name BuildFunctions)) 
{
    Import-Module -Name ".\AssemblyVersioningFunctions"
}

if ($assemblyVersion -eq "")
{
    $assemblyVersion = "1.0.0.0"
    $fileAssemblyVersion = "1.0.J.B"
}

Update-SourceVersion $srcPath $assemblyVersion $fileAssemblyVersion