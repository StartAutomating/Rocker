#requires -Module PSDevOps
Import-BuildStep -SourcePath (
    Join-Path $PSScriptRoot 'GitHub'
) -BuildSystem GitHubWorkflow

Push-Location ($PSScriptRoot | Split-Path)
New-GitHubWorkflow -Name "Analyze, Test, Tag, and Publish" -On Push,
    PullRequest, 
    Demand -Job TestPowerShellOnLinux, 
    TagReleaseAndPublish, 
    BuildRocker -OutputPath .\.github\workflows\BuildRocker.yml

Pop-Location