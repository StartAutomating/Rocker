Write-FormatView -TypeName docker.help -Action {
    Write-FormatViewExpression -Property Usage -Style 'Foreground.Cyan'
    Write-FormatViewExpression -Newline


    Write-FormatViewExpression -If { $_.Description } -ScriptBlock {
        @(
            [Environment]::NewLine
            $_.Description
            [Environment]::NewLine
        ) -join ''

    }  -Style 'Foreground.Green'
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -If { $_.Options } -ScriptBlock {
        $_.Options | 
            Select-Object OptionName, Type, Description | 
            Format-Table -Wrap |
            Out-String
    } -Style 'Foreground.Blue'

    Write-FormatViewExpression -If { $_.Commands } -ScriptBlock {
        $_.Commands | 
            Select-Object CommandName, Description | 
            Format-Table -Wrap |
            Out-String
    } -Style 'Foreground.BrightBlue'
}