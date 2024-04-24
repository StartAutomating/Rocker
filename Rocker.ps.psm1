[Include('*-*.ps1')]$PSScriptRoot

$myModule = $MyInvocation.MyCommand.ScriptBlock.Module
$Rocker = $myModule
$Rocker.pstypenames.insert(0,'Rocker')

New-PSDrive -Name Rocker -PSProvider FileSystem -Scope Global -Root $PSScriptRoot -ErrorAction Ignore

$MyModuleCommands = @(
        foreach ($CommandFound in
            $ExecutionContext.SessionState.InvokeCommand.GetCommands('*','Alias,Function,Cmdlet',$true)
        ) {
            if ($CommandFound.Module -eq $myModule) {
                $CommandFound
            }
        }
    )

Write-Verbose "$($MyModuleCommands.Count) module commands"

:nextCommand foreach ($myModuleCommand in $MyModuleCommands) {
    $TheCommandName = $myModuleCommand.Name
    if ($myModuleCommand.ResolvedCommand) {
        $applicationExists = $ExecutionContext.SessionState.InvokeCommand.GetCommand($myModuleCommand.Name,'Application')
        if (-not $applicationExists) {
            Write-Warning "'$($myModuleCommand.Name)' was not found in the path.  Rocker cannot rock this command until it is installed."
        }
        $myModuleCommand = $myModuleCommand.ResolvedCommand
    }
    if ($myModuleCommand.ScriptBlock.Attributes) {
        foreach ($attr in $myModuleCommand.ScriptBlock.Attributes) {
            if ($attr -is [ArgumentCompleter]) {
                Write-Verbose "Registering Complete for $($myModuleCommand.Name)"
                Register-ArgumentCompleter -CommandName $TheCommandName -ScriptBlock $attr.ScriptBlock
                continue nextCommand
            }            
        }
    }
}

Export-ModuleMember -Function * -Variable Rocker -Alias *
