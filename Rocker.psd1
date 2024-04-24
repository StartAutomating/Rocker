@{
    RootModule = 'Rocker.psm1'
    ModuleVersion = '0.1.2'

    Guid = '0281178d-a36f-4a0d-9145-9f7fd646ad85'
    Copyright = '2024 Start-Automating'
    CompanyName = 'Start-Automating'
    Author = 'James Brundage'

    Description   = 'Rock Docker with PowerShell'    

    TypesToProcess = 'Rocker.types.ps1xml'
    FormatsToProcess = 'Rocker.format.ps1xml'

    PrivateData = @{
        PSData = @{
            ProjectURI = 'https://github.com/StartAutomating/Rocker'
            LicenseURI = 'https://github.com/StartAutomating/Rocker/blob/main/LICENSE'
            IconURI    = 'https://raw.githubusercontent.com/StartAutomating/Rocker/main/Assets/Rocker.png'
            Tags       = 'PowerShell', 'docker', 'containers'
            Tagline = 
                'Rock Docker in PowerShell', 
                'Docker Rocks in PowerShell',
                'Control Containers with PowerShell',
                'Scripts that make Docker sing',
                'Cooler Containers with PowerShell',
                'Better Docker with PowerShell'
            ReleaseNotes = @'
> Rock Docker with PowerShell
> Like It? [Star It](https://github.com/StartAutomating/Rocker)
> Love It? [Support It](https://github.com/sponsors/StartAutomating)

## Rocker 0.1.2:

* Rocker in Docker (#72)
  * DockerFile (#73)
  * Publishing to ghcr.io (#74)
* docker diff
  * ParseDiff (#70)
  * Formatting (#71)
* General Improvements
  * Tests (#65)
  * Better Error Experience when Missing Docker (#66)
  * Get-Rocker parsing improvements (#75)

---

Additional history available in the [CHANGELOG](https://github.com/StartAutomating/Rocker/blob/main/CHANGELOG.md)
'@
        }
        CommandTypes = @{
            "Rocker.Function" = @{
                Pattern = "[R|d]ocker\p{P}(?<CommandName>.+?)\p{P}"
                ExcludeCommandType = '(?>Application|Script|Cmdlet)'
            }
        }
    }
}
