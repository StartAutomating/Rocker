# The first layer is the base image for PowerShell
FROM mcr.microsoft.com/powershell AS PowerShell

# The next layer is the "Docker In Docker" image from Docker.
FROM docker:dind AS Docker

# Copy essentially everything from the PowerShell image into the final image
COPY --from=PowerShell /usr /usr
COPY --from=PowerShell /lib /lib
COPY --from=PowerShell /lib64 /lib64
COPY --from=PowerShell /bin /bin
COPY --from=PowerShell /opt /opt

SHELL ["/bin/pwsh", "-nologo", "-command"]

# Copy the module into the container
RUN --mount=type=bind,src=./,target=/Initialize ./Initialize/Container.init.ps1

# Set the entrypoint to the script we just created.
ENTRYPOINT [ "/Container.start.sh" ]

