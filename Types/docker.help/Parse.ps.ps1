[ValidatePattern("^(?>docker(?>-|\s)compose)?\s{1,}help|usage:)")]
param(
[vfp()]
[string]
$Content,

[string]
$CommandLine
)

begin {
    $dockerCommandPattern = '^\s{2}(?<CmdName>\w+)(?<IsPlugin>\*)?\s+(?<Description>.+$)'    
    $DockerOptionsPattern = '\s{2,}(?:\-{1,2}\w+)'
    
    $CurrentOutput = $null
    
    $DockerCommandHelp = object @{
        PSTypeName  = 'Docker.Help'
        CommandLine = $CommandLine
        Usage       = ''
        Description = ''
        Options     = @()
        Commands    = @()            
    }

    $inOptions  = $false
    $inCommands = $false
}

process {
    foreach ($line in $content -split '[\r\n]+') {
        if (($line -match '^Usage\:') -and (-not $DockerCommandHelp.Usage)) {
            $DockerCommandHelp.Usage = $line -replace '^Usage\:\s{0,}'
        }
        elseif ($line -match '^\S+' -and $line -notmatch '^.+?\:$') {
            if (-not $DockerCommandHelp.Description) {
                $DockerCommandHelp.Description = $line
            } else {
                $DockerCommandHelp.Description += ([Environment]::NewLine + $line)
            }            
        }
        if ($line -match $DockerOptionsPattern) {
            if ($CurrentOutput) {
                $DockerCommandHelp.Options += $CurrentOutput
            }
            $inOptions = $true
            if ($line -match '--[\w\-]+\s(?<type>\S+)') {
                $CurrentOutput = 
                    object @{
                        PSTypeName = 'Docker.Argument'
                        OptionName = $(@($line -split '\s' -match '^-{2}')[0]) -as [string]
                        OptionFlag = $line -split '\s' -match '^-\w' -replace '\,\s{,0}$'
                        Type = $matches.type
                        CommandLine = $CommandLine
                        Description = @($line -split '\s{2,}')[-1]
                    }
            } else {
                $CurrentOutput =
                    object @{
                        PSTypeName = 'Docker.Argument'
                        OptionName = $(@($line -split '\s' -match '^-{2}')[0]) -as [string]
                        OptionFlag = $line -split '\s' -match '^-\w' -replace '\,\s{,0}$'
                        CommandLine = $CommandLine
                        Description = @($line -split '\s{2,}')[-1]
                    }
            }
            
            
        }
        elseif ($line -match $dockerCommandPattern) {
            $inCommands = $true
            if ($matches.CmdName -eq 'docker') { continue }

            if ($CurrentOutput) {
                if ($CurrentOutput.OptionName) {
                    $DockerCommandHelp.Options += $CurrentOutput
                } else {
                    $DockerCommandHelp.Commands += $CurrentOutput
                }
                
            }
            $CurrentOutput = 
                object @{
                    PSTypeName = 'Docker.Command'
                    CommandName = $matches.CmdName
                    Description = $matches.Description
                    IsPlugin = $matches.IsPlugin -as [bool]
                }
            if ($CurrentOutput.CommandName -match '^\s{0,}$') {
                $CurrentOutput = $null
            }
        }
        elseif ($line -match '^\s{8,}' -and $CurrentOutput) {
            $CurrentOutput.Description += ($line -replace '^\s{8,}', ' ')
        }
    }
}

end {
    if ($CurrentOutput) {
        if ($CurrentOutput.CommandName) {
            $DockerCommandHelp.Commands += $CurrentOutput
        } else {
            $DockerCommandHelp.Options += $CurrentOutput
        }        
    }
    $DockerCommandHelp
}