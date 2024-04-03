@{
    RootModule = 'Rocker.psm1'
    ModuleVersion = '0.1'

    Description   = 'Rock Docker with PowerShell'

    TypesToProcess = 'Rocker.types.ps1xml'
    FormatsToProcess = 'Rocker.format.ps1xml'

    PrivateData = @{
        PSData = @{
            Tagline = 
                'Rock Docker in PowerShell', 
                'Docker Rocks in PowerShell',
                'Control Containers with PowerShell',
                'Scripts that make Docker sing',
                'Cooler Containers with PowerShell',
                'Better Docker with PowerShell'
        }
        CommandTypes = @{
            "Rocker.Function" = @{
                Pattern = "Rocker\.(?<CommandName>.+?)\.(?>Command|Function|Extension|Cmd|Func|Ext|X)$"
                ExcludeCommandType = '(?>Application|Script|Cmdlet)'
            }
            "Rocker.Parser" = @{
                Pattern = "Rocker\.(?<CommandName>.+?)\.(?:Parse[sr]?)$"
                ExcludeCommandType = '(?>Application|Script|Cmdlet)'
            }
            "Rocker.Parameter" = @{
                Pattern = "Rocker\.(?<CommandName>.+?)\.(?>Parameters?|Params?|Arguments?|Args?|Inputs?)$"
                ExcludeCommandType = '(?>Application|Script|Cmdlet)'
            }
        }
    }
}
