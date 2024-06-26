<div align='center' style='overflow: visible'>
<img src='Assets/Rocker.png' style='width:50%;overflow: visible' />
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

~~~PowerShell

        # Get Docker Help
        docker help

~~~

~~~PowerShell

        # Get Docker Help for a specific command
        docker help run

~~~

~~~PowerShell

        # Run a script in a container
        docker run mcr.microsoft.com/powershell {
            "Hello from Docker! $pid"
        }

~~~

~~~PowerShell

        # Run an nginx container, publishing port 8080 on the host.
        docker run --detach @{8080=80} nginx

~~~

~~~PowerShell

        # Run a script in a container, 
        # mount the current directory,
        # and set an environment variable.
        docker run @{
            "$pwd"="/mnt"
            message='Hello from Docker!'
        } mcr.microsoft.com/powershell {
            "$($env:message) $(@(Get-ChildItem /mnt -recurse -File).Length) files mounted."
        }

~~~

~~~PowerShell

        # List all containers
        docker container ls |
            docker diff # show their differences from the image.

~~~

~~~PowerShell

        # List all containers,
        docker container ls |            
            docker container pause
            # and pause them.

~~~

~~~PowerShell

        # List all containers,
        docker container ls |            
            docker container unpause 
            # and start them up again.

~~~

~~~PowerShell

        # List all containers.
        docker container ls |            
            docker history 
            # get their history

~~~

~~~PowerShell

        # Stop all running containers.
        docker container ls |
            docker container stop

~~~

~~~PowerShell

        # Get system disk information
        docker system df

~~~

~~~PowerShell

        # Get system info
        docker system info

~~~
