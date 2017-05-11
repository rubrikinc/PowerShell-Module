﻿#requires -Version 3
function Export-RubrikReport
{
  <#  
      .SYNOPSIS
      Retrieves link to a CSV file for a Rubrik Envision report

      .DESCRIPTION
      The Export-RubrikReport cmdlet is used to pull the link to a CSV file for a Rubrik Envision report

      .NOTES
      Written by Bas Vinken for community usage
      Twitter: @bvinken
      GitHub: basvinken

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Export-RubrikReport -id '11111111-2222-3333-4444-555555555555' -timezone_offset 120
      This will return the link to a CSV file for report id "11111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikReport -Name 'Protection Tasks Details' | Export-RubrikReport
      This will return the link to a CSV file for report named "Protection Tasks Details"
  #>

  [CmdletBinding()]
  Param(
    # ID of the report.	
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Timezone offset from UTC in minutes.	
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('timezone_offset')]
    [String]$TimezoneOffset = 0,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = (Get-RubrikAPIData -endpoint $function).$api
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
