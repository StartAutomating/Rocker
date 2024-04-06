@{
    RootModule = 'Rocker.psm1'
    ModuleVersion = '0.1'

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
## Rocker 0.1

Rocking Docker with PowerShell

> Like It? [Star It](https://github.com/StartAutomating/Rocker)
> Love It? [Support It](https://github.com/sponsors/StartAutomating)


* Rocker is a module that rocks docker with PowerShell (#1)
    * It is built in github workflows, with the help of (#2)
    * PSDevOps (#2)    
    * EZOut (#3)
    * PipeScript (#4)
    * PSSVG (#5)
* Rocker exposes a single command, Get-Rocker (#7)
    * This overrides docker and docker-compose 
* Rocker exposes itself thru a variable ($Rocker)
    * This is formatted for sleekness and ease of use (#42)
* Rocker extends itself to provide an object model
    * It provides parsers in Rocker.get_Parsers (#12)
    * Rocker.Parsers.ForCommand (#15)
    * Rocker.Parsers.Validate (#17)
    * Rocker.Parsers.get_All (#14)  
    * These provide a basis for wrapping any application
    * Rocker.GetApplicationHelp (#10)
    * Rocker.ParseDockerJson (#11)
    * Any command line can be "rocked", and rocker will attempt to handle pipeline and complex input
    * Rocker.Add (#32)
    * Rocker.GetInputArguments (#30)
    * Rocker.GetInputTransforms (#52)
    * Rocker.Complete() will try to provide tab completion for any command (#31)
    * Rocker.get_Tagline (#41) will provide taglines
* Rocker maps any docker command to a pseudotype, so it can be extended  
    * docker.network.ls
    * docker.network.ls.NetworkID (#51)
    * docker.network.ls formatting (#50)
    * docker.network.ls.get_CreationTime ( #40)
    * docker.run
    * docker.run.Dictionary.Input (#54)
    * docker.run.ScriptBlock.Input (#53)
    * docker.build
    * docker.build.ParseBuild (#48)
    * docker history
    * docker history formatting (#49)
    * docker.logs
    * docker.logs.ContainerID.Input (#47)
    * docker.history
    * docker.history.Image.Input (#46)    
    * docker help
    * Parse (#19)
    * docker help formatting (#33)
    * docker.help.get_SupportsFormat (#22)
    * docker.help.get_OptionName (#21)
    * docker.help.get_CommandName (#20)
    * docker images
    * Docker.images formatting (#35)
    * docker.system.df
    * docker.system.df formatting (#45)
    * docker.kill
    * docker.kill.ContainerID.Input (#44)
    * docker.diff
    * docker.diff.ContainerID.Input (#43)
    * docker.container
    * docker.container.ContainerID.Input (#26)
    * docker.container.ls
        * docker.container.ls formatting (#34)
        * docker.container.ls.get_Uptime (#39)
        * docker.container.ls.get_VirtualSize (#38)
        * docker.container.ls.get_UniqueSize (#37)
        * docker.image.get_CreationTime (#28)
        * docker.container.ls.ContainerID (#34)
        * docker.container.ls.get_CreationTime (#24)
* Rocker supports sponsorship (#55)
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
