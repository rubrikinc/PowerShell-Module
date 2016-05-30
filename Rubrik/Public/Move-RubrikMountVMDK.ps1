﻿#Requires -Version 2
function Move-RubrikMountVMDK
{
    <#  
            .SYNOPSIS
            Moves the VMDKs from a Live Mount to another VM
            .DESCRIPTION
            The Move-RubrikMountVMDK cmdlet is used to attach VMDKs from a Live Mount to another VM, typically for restore or testing purposes.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Source Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$SourceVM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Target Virtual Machine',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$TargetVM,
        [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $true,Position = 3,HelpMessage = 'Backup date in your local clock format format',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Date,
        [Parameter(Mandatory = $false,Position = 4,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        ConnectTovCenter -vCenter $vCenter

        Write-Verbose -Message 'Creating an Instant Mount (clone) of the Source VM'

        New-RubrikMount -VM $SourceVM -Date $Date
        Start-Sleep -Seconds 2
        [array]$mounts = Get-RubrikMount -VM $SourceVM
        $i = 0
        
        Write-Verbose -Message 'Checking for quantity of mounts in the system'
        if ($mounts -ne $null) 
        {
            Write-Verbose -Message 'Finding the correct mount'
            foreach ($_ in $mounts.MountName)
            {            
                if ($_ -eq $null)
                {
                    break
                }
                $i++
            }
        
            While ($mounts[$i].MountName -eq $null)
            {
                [array]$mounts = Get-RubrikMount -VM $SourceVM
                Start-Sleep -Seconds 2
            }
        }
        else
        {
            Write-Verbose -Message 'No other mounts found, waiting for new mount to load'
            While ($mounts.MountName -eq $null)
            {
                [array]$mounts = Get-RubrikMount -VM $SourceVM
                Start-Sleep -Seconds 2
            }
        }
        Write-Verbose -Message 'Mount is online. vSphere data loaded into the system.'

        Write-Verbose -Message 'Gathering details on the Instant Mount'
        $MountVM = $null
        While ($MountVM.PowerState -ne 'PoweredOn')
        {
            $MountVM = Get-VM -Name $mounts[$i].MountName
            Start-Sleep -Seconds 2
        }

        Write-Verbose -Message 'Powering off the Instant Mount'
        $moref = $MountVM.Id.Substring($MountVM.Id.IndexOf('-')+1)
        $vmid = $mounts[$i].vCenterId + '-' + $moref
        Stop-RubrikVM -ID $vmid

        Write-Verbose -Message 'Gathering details on the Target VM'
        if (!$TargetVM) 
        {
            $TargetVM = $SourceVM
        }
        $TargetHost = Get-VMHost -VM $TargetVM

        Write-Verbose -Message 'Mounting Rubrik datastore to the Target Host'
        $MountDatastore = Get-VM $MountVM | Get-Datastore
        if (!(Get-VMHost $TargetHost | Get-Datastore -Name $MountDatastore)) 
        {
            $null = New-Datastore -Name $MountDatastore.Name -VMHost $TargetHost -NfsHost $MountDatastore.RemoteHost -Path $MountDatastore.RemotePath -Nfs
        }

        Write-Verbose -Message 'Migrating the Mount VMDKs to VM'
        [array]$MountVMdisk = Get-HardDisk $MountVM
        $MountedVMdiskFileNames = @()
        foreach ($_ in $MountVMdisk)
        {
            try
            {
                $null = Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
                $null = New-HardDisk -VM $TargetVM -DiskPath $_.Filename
                $MountedVMdiskFileNames += $_.Filename
            }
            catch
            {
                throw 'Unable to attach VMDKs to the TargetVM'
            }
        }
        
        Write-Verbose -Message 'Offering cleanup options'
        $title = 'Setup is complete!'
        $message = "A Mount of $SourceVM has been created, and all VMDKs associated with the mount have been attached.`rYou may now start testing.`r`rWhen finished:`rSelect YES to automatically cleanup the attached VMDKs and mount`rSelect NO to leave the mount and VMDKs intact."

        $yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', `
        'Automated Removal: This script will detatch the VMDK(s) and discard the Mount VM'

        $no = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No', `
        'Manual Removal: VMDK(s) will remain attached and Mount VM will remain in vCenter'

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

        $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

        switch ($result)
        {
            0 
            {
                Write-Verbose -Message 'Removing VMDKs from the VM'
                [array]$SourceVMdisk = Get-HardDisk $TargetVM
                foreach ($_ in $SourceVMdisk)
                {
                    if ($MountedVMdiskFileNames -contains $_.Filename)
                    {
                        Write-Verbose -Message "Removing $_ from $TargetVM"
                        Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
                    }
                }
        
                Write-Verbose -Message 'Deleting the Instant Mount'
                Remove-RubrikMount -RubrikID $mounts[$i].RubrikID              
            }
            1 
            {
                Write-Verbose -Message 'You selected No. Exiting script'
            }
        }

    } # End of process
} # End of function
