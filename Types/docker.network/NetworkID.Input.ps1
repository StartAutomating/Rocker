<#
.SYNOPSIS
    Gets a network ID as `docker network` input.
.DESCRIPTION
    Converts a network ID to a list of arguments to `docker network`.
#>
param(
# The Container ID.
[string]
$NetworkID
)

if ($NetworkID) {
    $NetworkID
}

