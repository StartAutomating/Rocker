<#
.SYNOPSIS
    Adds to Rocker
.DESCRIPTION
    Adds commands to Rocker.  
#>
param()

$unrolledArgs = 
    $args | . { process { $_  } }

foreach ($arg in $unrolledArgs) {
    if ($arg -is [Management.Automation.ApplicationInfo]) {
        if (-not $this.'.ApplicationMap') {
            Add-Member -MemberType NoteProperty -Name '.ApplicationMap' -Value (
                [Ordered]@{}
            ) -InputObject $this -Force
        }
        $this.'.ApplicationMap'[$arg.Name] = $arg
    }
    elseif ($arg -is [Management.Automation.FunctionInfo]) {
        if (-not $this.'.FunctionMap') {
            Add-Member -MemberType NoteProperty -Name '.FunctionMap' -Value (
                [Ordered]@{}
            ) -InputObject $this -Force
        }
        $this.'.FunctionMap'[$arg.Name] = $arg
    }
}