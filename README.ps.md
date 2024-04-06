<div align='center' style='overflow: visible'>
<img src='Assets/Rocker-animated.svg' style='width:50%;overflow: visible' />
</div>

## Rocker

Rock Docker with PowerShell

### What is Rocker?

Rocker is a PowerShell module that makes Docker a bit cooler.

It allows docker to work with PowerShell's object pipeline, so you can pipe one step into the next.

It also gives you tab completion for any command in docker.

### Installing and Importing

~~~PowerShell
Install-Module Rocker -Scope CurrentUser
Import-Module Rocker -Force -PassThru
~~~

### Examples

~~~PipeScript{
    Import-Module .\
    @(foreach ($example in (Get-Command Get-Rocker).Examples) {
        "~~~PowerShell"
        $example
        "~~~"
    }) -join ([Environment]::Newline * 2)
}
~~~