function Invoke-HCDCDiag {
    <#
    .SYNOPSIS
        Invokes dcdiag.exe and returns the results of the tests as an array of PowerShell objects.
    .DESCRIPTION
        Runs the dcdiag.exe utility based on the input parameters. The text results of the utility are parsed and returned as rich PowerShell objects.
    .EXAMPLE
        Invoke-HCDCDiag

        This runs the default dcdiag tests against the local computer.
    .EXAMPLE
        Invoke-HCDCDiag -ComputerName LONDC01.contoso.com -Tests Connectivity, Advertising, Replications

        This runs only the Connectivity, Advertising and Replications tests against the above domain controller.
    .EXAMPLE
        Invoke-HCDCDiag -ComputerName LONDC01.contoso.com -Tests All -Skip DNS

        This runs all the dcdiag tests against the above server, apart from the DNS test.
    .NOTES
        https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc731968(v=ws.11)
    #>

    [CmdletBinding()]
    param(
        # The domain controller(s) to target for the dcdiag test.
        # If this parameter is not specified, it will run against the local machine.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $ComputerName = $env:COMPUTERNAME,

        # The dcdiag test(s) to run.
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'All',
            'Advertising',
            'CheckSDRefDom',
            'CheckSecurityError',
            'Connectivity',
            'CrossRefValidation',
            'CutoffServers',
            'DFSREvent',
            'DNS',
            'FrsEvent',
            'FrsSysVol',
            'FsmoCheck',
            'Intersite',
            'KccEvent',
            'KnowsOfRoleHolders',
            'LocatorCheck',
            'MachineAccount',
            'NCSecDesc',
            'NetLogons',
            'ObjectsReplicated',
            'OutboundSecureChannels',
            'Replications',
            'RidManager',
            'Services',
            'SysVolCheck',
            'SystemLog',
            'Topology',
            'VerifyEnterpriseReferences',
            'VerifyReferences',
            'VerifyReplicas'
        )]
        [String[]]
        $Test,

        # The dcdiag test(s) to skip.
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'Advertising',
            'CheckSDRefDom',
            'CheckSecurityError',
            'Connectivity',
            'CrossRefValidation',
            'CutoffServers',
            'DFSREvent',
            'DNS',
            'FrsEvent',
            'FrsSysVol',
            'FsmoCheck',
            'Intersite',
            'KccEvent',
            'KnowsOfRoleHolders',
            'LocatorCheck',
            'MachineAccount',
            'NCSecDesc',
            'NetLogons',
            'ObjectsReplicated',
            'OutboundSecureChannels',
            'Replications',
            'RidManager',
            'Services',
            'SysVolCheck',
            'SystemLog',
            'Topology',
            'VerifyEnterpriseReferences',
            'VerifyReferences',
            'VerifyReplicas'
        )]
        [Alias('SkipTest', 'Exclude', 'ExcludeTest')]
        [String[]]
        $Skip
    )

    $Function_Name = (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Name
    $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Verbose ('{0}|Arguments: {1} - {2}' -f $Function_Name, $_.Key, ($_.Value -join ' ')) }

    try {
        Test-DCDiag

        $Common_Arguments = [System.Collections.Generic.List[String]]@('/v')
        $Select_Parameters = @{}
        if ($PSBoundParameters.ContainsKey('Test')) {
            if ($Test -contains 'All') {
                $Common_Arguments.Add('/c')
            } else {
                $Select_Parameters['Test'] = @()
                foreach ($ThisTest in $Test) {
                    $Common_Arguments.Add(('/test:{0}' -f $ThisTest))
                    $Select_Parameters['Test'] += $ThisTest
                }
            }
        }
        if ($PSBoundParameters.ContainsKey('Skip')) {
            $Select_Parameters['Skip'] = @()
            foreach ($ThisSkip in $Skip) {
                $Common_Arguments.Add(('/skip:{0}' -f $ThisSkip))
                $Select_Parameters['Skip'] += $ThisSkip
            }
        }

        foreach ($ThisComputer in $ComputerName) {
            $Server = '/s:{0}' -f $ThisComputer

            Write-Verbose ('{0}|Running command line: dcdiag.exe {1} {2}' -f $Function_Name, ($Common_Arguments -join ' '), $Server)
            & 'dcdiag.exe' $Common_Arguments $Server | Select-DCDiagResult @Select_Parameters
        }

    } catch {
        if ($_.FullyQualifiedErrorId -match '^HC-') {
            $Terminating_ErrorRecord = New-DefaultErrorRecord -InputObject $_
            $PSCmdlet.ThrowTerminatingError($Terminating_ErrorRecord)
        } else {
            throw
        }
    }
}
