
param(
[Parameter(Mandatory)]
[ScriptBlock]
$ScriptBlock
)

"pwsh"
"-encodedCommand"
[Convert]::ToBase64String([Text.Encoding]::Unicode.getBytes("$ScriptBlock"))