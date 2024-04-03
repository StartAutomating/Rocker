param(
[PSObject]
$Argument
)

$ThisScriptBlock = if ($this.Script) {
    $this.Script
} elseif ($this.ScriptBlock) {
    $this.ScriptBlock
}

$validationAttributes =
    foreach ($attribute in $ThisScriptBlock.Attributes) {
        if ($attribute -is [ValidateScript]) {
            $attribute
        }
        if ($attribute -is [ValidatePattern]) {
            $attribute
        }
    }

if (-not $validationAttributes) { return $true}

:SomethingIsValid do {

    foreach ($attribute in $validationAttributes) {
        if ($attribute -is [ValidateScript]) {
            $this = $_ = $Argument
            $isValid = & $attribute.ScriptBlock $this
            if ($isValid) {
                break SomethingIsValid
            }
        }
        if ($attribute -is [ValidatePattern]) {
            if (
                [Regex]::new($attribute.RegexPattern, $attribute.Options, "00:00:00.1").IsMatch("$Argument")
            ) {
                break SomethingIsValid
            }
        }
    }

    return $false 


} while ($false)

return $true
