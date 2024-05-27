Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -Name Default -Action {
    Write-FormatViewExpression -ScriptBlock {
        $_.RepoTags        
    } -Style 'Foreground.Cyan'

    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -ScriptBlock {
        "$(if ($_.Size -gt 1GB) {
            ($_.Size / 1GB) + "gb"
        } elseif ($_.Size -gt 1MB) {
            ($_.Size / 1MB) + "mb"
        } elseif ($_.Size -gt 1KB) {
            ($_.Size / 1KB) + "kb"
        } else {
            $_.Size
        })"
    } -Style 'Foreground.Blue'
    
    Write-FormatViewExpression -Text {
        " @ "
    } -Style 'Foreground.Cyan'

    Write-FormatViewExpression -ScriptBlock {
        ($_.Created -as [DateTime]).ToLongDateString() + " " + ($_.Created -as [DateTime]).ToLongTimeString()
    } -Style 'Foreground.Blue'
    
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -Action {
        $_.Id        
    } -Style 'Foreground.Green'    
}

Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -Name json -Action {
    Write-FormatViewExpression -Action {
        $_ | ConvertTo-Json -Depth 10
    } 
}

Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -Name Default -Property RepoTags, Size -VirtualProperty @{
    Size = {
        if ($_.Size -gt 1GB) {
            ($_.Size / 1GB) + "gb"
        } elseif ($_.Size -gt 1MB) {
            ($_.Size / 1MB) + "mb"
        } elseif ($_.Size -gt 1KB) {
            ($_.Size / 1KB) + "kb"
        } else {
            $_.Size
        }
    }
    RepoTags =  { $_.RepoTags -join ' '}
}