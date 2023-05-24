function Test-DCDiag {
    <#
    .SYNOPSIS
        Test that dcdiag.exe is found in the PATH.
    .DESCRIPTION
        A small function to validate that dcdiag.exe is found in the PATH.
    .EXAMPLE
        Test-DCDiag
    #>

    [CmdletBinding()]
    param()

    try {
        $null = Get-Command -Name 'dcdiag.exe' -ErrorAction 'Stop'
    } catch {
        $Terminating_ErrorRecord_Parameters = @{
            'Exception' = $_.Exception
            'ID'        = 'HC-DCDiag-NotFound'
            'Category'  = 'ObjectNotFound'
            'Message'   = 'Unable to find "dcdiag.exe" in PATH'
        }
        $Terminating_ErrorRecord = New-ErrorRecord @Terminating_ErrorRecord_Parameters
        $PSCmdlet.ThrowTerminatingError($Terminating_ErrorRecord)
    }
}
