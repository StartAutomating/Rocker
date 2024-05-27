<#
.SYNOPSIS
    ContainerID Input
.DESCRIPTION
    Allows the ContainerID to be passed in as a parameter (from pipelined objects)
#>
param(
# The Container ID.
[string]
$ContainerID
)

if ($ContainerID) {
    $ContainerID
}

