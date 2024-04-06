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
        if ($potentialInputParameter.ParameterType -in [string], [switch], [bool]) { continue }    

        if ($currentInputObject -as $potentialInputParameter.ParameterType) {
            $inputMethodSplat[$potentialInputParameter.Name] = $currentInputObject
            break
        }
    }

    # If any parameters were found, we can run the input method
    if ($inputMethodSplat.Count) {
        $inputMethodSplat.psobject.properties.Add([PSNoteProperty]::new('Command', $inputMethod.Script))
        $inputMethodSplat
    }
})
