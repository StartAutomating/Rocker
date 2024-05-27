Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -Name Default -Action {
    Write-FormatViewExpression -ScriptBlock {
        if ($_.RepoTags) {
            $_.RepoTags   
        } elseif ($_.Config.Image) {
            $_.Config.Image
        }      
    } -Style 'Foreground.Cyan'

    Write-FormatViewExpression -Newline
    
    Write-FormatViewExpression -ScriptBlock {
        $_.Os, $_.Architecture -join '/'
    } -Style 'Foreground.Cyan' -If { $_.Os -and $_.Architecture}

    Write-FormatViewExpression -ScriptBlock {
        " $(if ($_.Size -gt 1GB) {
            '' + [Math]::Round(($_.Size / 1gb), 2) + "gb"
        } elseif ($_.Size -gt 1MB) {
            '' + [Math]::Round(($_.Size / 1mb), 2) + "mb"
        } elseif ($_.Size -gt 1KB) {
            '' + [Math]::Round(($_.Size / 1KB), 2) + "kb"
        } else {
            $_.Size
        })"
    } -Style 'Foreground.Blue' -If { $_.Size }
    
    Write-FormatViewExpression -ScriptBlock { " @ " } -Style 'Foreground.Cyan' -If { $_.Size }

    Write-FormatViewExpression -ScriptBlock {
        ($_.Created -as [DateTime]).ToLongDateString() + " " + ($_.Created -as [DateTime]).ToLongTimeString()
    } -Style 'Foreground.Blue'
    
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -If { $_.HostConfig.PortBindings } -ScriptBlock {
        (@(foreach ($portBinding in $_.HostConfig.PortBindings.psobject.properties) {
            $($portBinding.value.HostIP, $portBinding.value.HostPort -join '/') + '->' + $portBinding.Name
        }) -join [Environment]::NewLine) + [Environment]::NewLine
    } -Style 'Foreground.Yellow'

    Write-FormatViewExpression -ScriptBlock {
        $_.Id -replace '^sha256:'
    }        
}

Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -Name json -Action {
    Write-FormatViewExpression -ScriptBlock {
        $_ | ConvertTo-Json -Depth 10
    } 
}

Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -Name labels -Action {
    Write-FormatViewExpression -ScriptBlock {
        if ($PSStyle) {
            $PSStyle.OutputRendering = 'Ansi'
        }        
        $_.Config.labels | Format-List | Out-String
    }
}

Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -Name Default -Property RepoTags, Size -VirtualProperty @{
    Size = {
        "$(if ($_.Size -gt 1GB) {
            '' + [Math]::Round(($_.Size / 1gb), 2) + "gb"
        } elseif ($_.Size -gt 1MB) {
            '' + [Math]::Round(($_.Size / 1mb), 2) + "mb"
        } elseif ($_.Size -gt 1KB) {
            '' + [Math]::Round(($_.Size / 1KB), 2) + "kb"
        } else {
            $_.Size
        })"
    }
    RepoTags =  { $_.RepoTags -join ' '}
}
