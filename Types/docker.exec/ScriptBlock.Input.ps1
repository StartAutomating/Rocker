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
    "-encodedcommand"
    if ($ScriptBlock.NoExit) {
        "-noexit"
    }
    if (-not $ScriptBlock.UseProfile) {
        "-noprofile"
    }
    [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("$ScriptBlock"))
}

