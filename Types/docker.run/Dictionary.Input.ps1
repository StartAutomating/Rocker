
param(
[Parameter(Mandatory)]
[Collections.IDictionary]
$Dictionary
)

if (-not $Dictionary.Count) { return }
foreach ($keyValuePair in $Dictionary.GetEnumerator()) {
    # If it's a path, treat it as a --volume
    if ($keyValuePair.Key -match '[\\/]')
    {
        "--volume"
        "$($keyValuePair.Key):$($keyValuePair.Value)"
    }
    # Otherwise, treat it as an environment variable
    else
    {
        "--env"
        "$($keyValuePair.Key)=$($keyValuePair.Value)"
    }
}