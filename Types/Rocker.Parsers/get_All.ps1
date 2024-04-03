@(foreach ($property in $this.psobject.properties) {
    if (-not $property.IsInstance) { continue } 
    if (-not $property -is [psnoteproperty]) { continue } 
    $property.Value
})
