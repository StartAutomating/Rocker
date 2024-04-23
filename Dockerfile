FROM mcr.microsoft.com/powershell AS PowerShell

FROM docker:dind AS Docker

COPY --from=PowerShell /usr /usr
COPY --from=PowerShell /opt /opt
COPY --from=PowerShell /etc /etc
COPY --from=PowerShell /lib /lib
COPY --from=PowerShell /lib64 /lib64
COPY --from=PowerShell /bin /bin

ENV PSModulePath ./Modules
COPY ./ ./Modules/Rocker 
RUN pwsh -c "New-Item -ItemType File -Path \$Profile -Force -Value 'Import-Module Rocker'"
RUN pwsh -c "New-Item -Path ./start.sh -Value (@('#!/bin/sh','dockerd >/docker.log 2>&1 3>&1 4>&1  & pwsh -nologo') -join [Environment]::Newline) -Force; chmod +x ./start.sh"
ENTRYPOINT [ "/start.sh" ]





