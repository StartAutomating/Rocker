# The first layer is the base image for PowerShell
FROM mcr.microsoft.com/powershell AS PowerShell

# The next layer is the "Docker In Docker" image from Docker.
FROM docker:dind AS Docker

# Copy essentially everything from the PowerShell image into the final image
COPY --from=PowerShell /usr /usr
COPY --from=PowerShell /opt /opt
COPY --from=PowerShell /etc /etc
COPY --from=PowerShell /lib /lib
COPY --from=PowerShell /lib64 /lib64
COPY --from=PowerShell /bin /bin

# Set the module name to the name of the module we are building
ARG ModuleName=Rocker

# Copy the module into the container
COPY . ./usr/local/share/powershell/Modules/$ModuleName

# Create a profile
RUN pwsh -c "New-Item -ItemType File -Path \$Profile -Force"
# Add the module to the profile
RUN pwsh -c "Add-Content -Path \$Profile -Value 'Import-Module $ModuleName'"

# Now we need to be a little creative. We need to start the Docker daemon, but we also need to start PowerShell.
# We can't just run two commands in the CMD or ENTRYPOINT, so we'll create a script to do it.
# (for bonus points, we need to redirect the output of the Docker daemon to a file so that it doesn't interfere with PowerShell)
RUN pwsh -c "New-Item -Path ./start.sh -Value (@('#!/bin/sh','dockerd > /dockerd.log 2>&1 3>&1 4>&1 & pwsh -nologo \$@') -join [Environment]::Newline) -Force; chmod +x ./start.sh"

# Set the entrypoint to the script we just created.
ENTRYPOINT [ "/start.sh" ]

