﻿function Start-RubrikVM
{
    <#  
            .SYNOPSIS
            Powers on a virtual machine within a connected Rubrik vCenter.
            .DESCRIPTION
            The Stop-RubrikVM cmdlet is used to send a power on request to any virtual machine visible to a Rubrik cluster.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Start-RubrikVM -VM 'Server1'
            This will send a power on request to Server1
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Gathering the VM ID'
        [string]$vmid = ((Get-RubrikVM -VM $VM).id)

        Write-Verbose -Message 'Powering on the VM'
        $uri = 'https://'+$Server+'/vm/power'

        try 
        {
            $body = @{
            vmId = $vmid
            powerState = $true
            }

            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Post -Body (ConvertTo-Json -InputObject $body)
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function