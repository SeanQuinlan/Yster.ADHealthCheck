function Select-DCDiagResult {
    <#
    .SYNOPSIS
        Converts the text output from dcdiag.exe into a PowerShell object.
    .DESCRIPTION
        Parses the output from dcdiag.exe and uses a regular expression to extract the name, result, test object and the output from the test (if applicable).
    .EXAMPLE
        dcdiag.exe /s:dc01.contoso.com | Select-DCDiagResult
    #>

    [CmdletBinding()]
    param(
        # The input object.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        # The test(s) to include in the output.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Test,

        # The test(s) to exclude from the output.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Skip
    )

    begin {
        $Function_Name = (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Name
        $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Verbose ('{0}|Arguments: {1} - {2}' -f $Function_Name, $_.Key, ($_.Value -join ' ')) }
        $CompactedInput = [System.Collections.Generic.List[String]]@()
    }

    process {
        if ($InputObject.Trim()) {
            $CompactedInput.Add($InputObject.Trim())
        }
    }

    end {
        $Found_Error = $CompactedInput -match 'Ldap search capability attribute search failed on server|Could not find home server'
        if ($Found_Error) {
            $Terminating_ErrorRecord_Parameters = @{
                'Exception' = 'System.InvalidOperationException'
                'ID'        = 'HC-DCDiag-NotADomainController'
                'Category'  = 'ConnectionError'
                'Message'   = 'Server does not appear to be a domain controller'
            }
            $Terminating_ErrorRecord = New-ErrorRecord @Terminating_ErrorRecord_Parameters
            $PSCmdlet.ThrowTerminatingError($Terminating_ErrorRecord)
        }

        $TestMatchRegex = [Regex]'(?sm)^Starting test\: (?<TestName>.*?)$(?<TestOutput>.*?)^\.+\s(?<TestObject>.*?)\s(?<Result>passed|failed) test[ \r\n].*?$'
        $TestMatches = ($TestMatchRegex).Matches(($CompactedInput -join [System.Environment]::NewLine))

        $TestResults = foreach ($ThisMatch in $TestMatches) {
            $TestName = $ThisMatch.Groups.Item('TestName').Value.Trim()
            Write-Verbose ('{0}|Processing TestName: {1}' -f $Function_Name, $TestName)
            if (($Test -and ($Test -notcontains $TestName)) -or ($Skip -and ($Skip -contains $TestName))) { continue }

            [pscustomobject]@{
                'Name'   = $TestName
                'Result' = (Get-Culture).TextInfo.ToTitleCase($ThisMatch.Groups.Item('Result').Value)
                'Target' = $ThisMatch.Groups.Item('TestObject').Value
                'Output' = $ThisMatch.Groups.Item('TestOutput').Value.Trim()
            }
        }

        return $TestResults
    }
}
