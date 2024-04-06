param(
$InputObject,

[PSObject[]]
$InputMethods
)

$currentInputObject = $InputObject

@(:nextInputMethod foreach ($inputMethod in $inputMethods) {
    $function:InputMethodFunction = $inputMethod.Script
    # We turn each input method into a function
    $InputMethodFunction = $ExecutionContext.SessionState.InvokeCommand.GetCommand('InputMethodFunction', 'Function')
    $inputMethodSplat = [Ordered]@{}

    # and then we can get the input parameters
    foreach ($potentialInputParameter in $InputMethodFunction.Parameters.Values) {
        # and try to get the values from the current input object.
        if ($null -ne $CurrentInputObject.($potentialInputParameter.Name)) {
            $inputMethodSplat[$potentialInputParameter.Name] = $CurrentInputObject.($potentialInputParameter.Name)
        } elseif ($potentialInputParameter.Aliases) {
            # (if we fail, we can try to find each of the aliases in the current object)
            foreach ($aliasName in $potentialInputParameter.Aliases) {
                if ($null -ne $CurrentInputObject.$aliasName) {
                    $inputMethodSplat[$potentialInputParameter.Name] = $CurrentInputObject.$aliasName
                    break
                }
            }
        }
    }

    # If any parameters were found, we can run the input method
    if ($inputMethodSplat.Count) {
        $inputMethodSplat.psobject.properties.Add('Command', $inputMethod.Script)
        $inputMethodSplat
    }
})
