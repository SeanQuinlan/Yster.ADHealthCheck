@{
    Path = "Yster.ADHealthCheck.psd1"
    OutputDirectory = "..\bin\Yster.ADHealthCheck"
    Prefix = '.\_PrefixCode.ps1'
    SourceDirectories = 'Classes','Private','Public'
    PublicFilter = 'Public\*.ps1'
    VersionedOutputDirectory = $true
}
