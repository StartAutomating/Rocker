Write-FormatView -TypeName Rocker -Action {
    
    Write-FormatViewExpression -Style "Foreground.Blue", "Bold" -Property Name
    Write-FormatViewExpression -Style "Foreground.Cyan" -Text ' @ '
    Write-FormatViewExpression -ScriptBlock {
        if ($PSStyle) {
            @(foreach ($versionPart in $_.Version.ToString() -split "\.") {
                @(
                    $PSStyle.Foreground.Cyan
                    $PSStyle.Bold
                    $versionPart
                    $PSStyle.Reset
                ) -join ''            
            }) -join "$(
                @(
                    $PSStyle.Foreground.Blue
                    '.'
                ) -join ''      
            )"
        } else {
            $_.ToString()
        }
    }
    
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -ScriptBlock {
        
        @(foreach ($row in 1..2) {
            $(
                if ($row -eq 1) { '▄' } else { '▄' }
            )
        }) -join [Environment]::NewLine
    } -Style Foreground.Cyan

    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -Newline
    
    Write-FormatViewExpression -Style "Foreground.Blue", "Italic" -ScriptBlock {
        $_.Taglines | Get-Random
    } 
    Write-FormatViewExpression -Newline

    <#Write-FormatViewExpression -Style "Foreground.Green" -ScriptBlock {
        $_.Description
    }#>

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline
}