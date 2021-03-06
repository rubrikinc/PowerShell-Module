Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikSupportTunnel' -Tag 'Public', 'Set-RubrikSupportTunnel' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.5'
    }
    #endregion
 
    Context -Name 'Parameter Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'inactivityTimeoutInSeconds'        = '1000'
                'port'                              = '11874'
                'isTunnelEnabled'                   = 'True'
            }
        }
        It -Name 'Enabling Tunnel' -Test {
            (Set-RubrikSupportTunnel -EnableTunnel).isTunnelEnabled |
                Should -BeExactly 'True'
        }
        
        It -Name 'Verify switch param - EnableTunnel:$true - Switch Param' -Test {
            $Output = & {
                Set-RubrikSupportTunnel -EnableTunnel -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*isTunnelEnabled*true*'
        }
        
        It -Name 'Verify switch param - EnableTunnel:$false - Switch Param' -Test {
            $Output = & {
                Set-RubrikSupportTunnel -EnableTunnel:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*isTunnelEnabled*false*'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 3
    }
}