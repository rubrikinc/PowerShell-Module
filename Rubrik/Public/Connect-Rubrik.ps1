﻿#Requires -Version 3
function Connect-Rubrik 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a token value for authentication

      .DESCRIPTION
      The Connect-Rubrik function is used to connect to the Rubrik RESTful API and supply credentials to the /login method.
      Rubrik then returns a unique token to represent the user's credentials for subsequent calls.
      Acquire a token before running other Rubrik cmdlets.
      Note that you can pass a username and password or an entire set of credentials.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Username admin
      This will connect to Rubrik with a username of "admin" to the IP address 192.168.1.1.
      The prompt will request a secure password.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Username admin -PasswordFile C:\pwd.txt
      
      To create the password file:
      Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File '.\pwd.txt'
      *********
      -> NOTE: Secure this file by locking down permissions so that only the users running the script have read-only access to it.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Username admin -Password (ConvertTo-SecureString "secret" -asplaintext -force)
      If you need to pass the password value in the cmdlet directly, use the ConvertTo-SecureString function.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Credential (Get-Credential)
      Rather than passing a username and secure password, you can also opt to submit an entire set of credentials using the -Credentials parameter.
  #>

  [CmdletBinding()]
  Param(
    # The IP or FQDN of any available Rubrik node within the cluster
    [Parameter(Mandatory = $true,Position = 0)]
    [ValidateNotNullorEmpty()]
    [String]$Server,
    # Username with permissions to connect to the Rubrik cluster
    # Optionally, use the Credential parameter
    [Parameter(Position = 1)]
    [String]$Username,
    # Password for the Username provided
    # Optionally, use the Credential parameter
    [Parameter(Position = 2)]
    [SecureString]$Password, 
    # Copy secure text password in file and provide PATH to that file
    [Parameter(Position = 3)]
    [String]$PasswordFile,
    # Credentials with permission to connect to the Rubrik cluster
    # Optionally, use the Username and Password parameters
    [Parameter(Position = 4)]
    [System.Management.Automation.CredentialAttribute()]$Credential
  )

  Process {

    # Helper function to allow self-signed certificates for HTTPS connections
    # This is required when using RESTful API calls over PowerShell
    UnblockSelfSignedCerts
    
    # Check to see if the user supplied any sort of credentials
    # If not, request credentials
    # If the user supplied a username and secure password, convert them into a Credential object
    Write-Verbose -Message 'Validating that login details were passed into username/password or credentials'
    if ($Username -and $PasswordFile)
    {
      $Password = Get-Content $PasswordFile | ConvertTo-SecureString
      $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
    }
    elseif ($Password -eq $null -and $Credential -eq $null)
    {
      Write-Warning -Message 'You did not submit a username, password, or credentials.'
      $Credential = Get-Credential -Message 'Please enter administrative credentials for your Rubrik cluster'
    }
    elseif ($Credential -eq $null)
    {
      $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
    }

    # Try to connect to the Rubrik node using different versions of the API
    # Essentially, we're just looping through newer-to-older Login endpoints to see which one exists
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('Login')

    foreach ($versionnum in $resources.Keys | Sort-Object -Descending)
    {
      # Load the version specific data from the resources array
      $version = $resources[$versionnum]
      
      Write-Verbose -Message "Connecting to $($version.URI)"
    
      # Create the URI
      $uri = 'https://'+$Server+$version.URI
      
      # Create the body
      $body = @{
        $version.Body[0] = $Credential.UserName
        $version.Body[1] = $Credential.GetNetworkCredential().Password
      }

      # Set the Method
      $method = $version.Method
      
      Write-Verbose -Message 'Submitting the request'
      try 
      {
        $r = Invoke-WebRequest -Uri $uri -Method: $method -Body (ConvertTo-Json -InputObject $body)
        $content = (ConvertFrom-Json -InputObject $r.Content)
        # If we find a successful call code and also a token, we know the request was successful
        # Anything else will trigger a throw, which will cause the catch to break the current loop and try another version
        if ($r.StatusCode -eq $version.SuccessCode -and $content.token -ne $null)
        {
          Write-Verbose -Message "Successfully acquired token: $($content.token)"
          break
        }
        else
        {
          throw "Unable to connect to the cluster"
        }
      }
      catch 
      {
      }
    }
    
      # Final throw for when all versions of the API have failed
        if ($content.token -eq $null) 
        {
          throw 'Unable to connect with any available API version'
        }

    Write-Verbose -Message 'Validate token and build Base64 Auth string'
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($($content.token)+':'))
    $head = @{
      'Authorization' = "Basic $auth"
    }

    Write-Verbose -Message 'Storing all connection details into $global:rubrikConnection'
    $global:rubrikConnection = @{
      userId = $content.userId
      token  = $content.token
      server = $Server
      header = $head
      time   = (Get-Date)
      api    = $versionnum
    }
        
    Write-Verbose -Message 'Adding connection details into the $global:RubrikConnections array'
    [array]$global:RubrikConnections += $rubrikConnection
    
    return $global:rubrikConnection

  } # End of process
} # End of function