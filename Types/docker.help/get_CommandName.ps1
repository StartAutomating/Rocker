@(foreach ($cmd in $this.Commands) {    
    $cmd.CommandName
}) -ne '' -as [string[]]