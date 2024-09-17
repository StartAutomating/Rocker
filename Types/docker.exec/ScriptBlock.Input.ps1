<#
.SYNOPSIS
    ScriptBlock Input
.DESCRIPTION
    Allows a ScriptBlock to be passed in as a parameter
#>
param(
# The ScriptBlock.
[ScriptBlock]
$ScriptBlock
)

if ($ScriptBlock) {
    "pwsh"
    if ($ScriptBlock.NoExit) {
        "-noexit"
    }
    if (-not $ScriptBlock.UseProfile) {
        "-noprofile"
    }
    "-encodedcommand"    
    [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("$ScriptBlock"))
}

