Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -ViewName Default -Action {
    Write-FormatViewExpression -Action {
        $_.RepoTags        
    } -Style 'Foreground.Cyan'

    Write-FormatViewExpression -Action {
        " ($(if ($_.Size -gt 1GB) {
            ($_.Size / 1GB) + "gb"
        } elseif ($_.Size -gt 1MB) {
            ($_.Size / 1MB) + "mb"
        } elseif ($_.Size -gt 1KB) {
            ($_.Size / 1KB) + "kb"
        } else {
            $_.Size
        }))"
    } -Style 'Foreground.Blue'
    
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -Action {
        $_.Id        
    } -Style 'Foreground.Green'

    

} -GroupByProperty Os

Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -ViewName json -Action {
    Write-FormatViewExpression -Action {
        $_ | ConvertTo-Json -Depth 10
    } 
} -GroupByProperty Os

Write-FormatView -TypeName docker.inspect, docker.image.inspect, docker.container.inspect -ViewName Default -Property RepoTags, Size -VirtualProperty @{
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
} -GroupByProperty Os