#!/bin/bash

# Check to see if docker or podman is installed.
# If podman is installed, then set an alias for podman to docker.
dockerAliasWasSet=0
if ! command -v docker &> /dev/null
then
    echo -e "docker not found. Checking for podman instead..."
    if ! command -v podman &> /dev/null
    then
        echo -e "Neither docker, nor podman was found. Exiting."
        exit
    else
        echo -e "Setting an alias for podman to resolve to docker.\n"
        alias docker=$(command -v podman)
        dockerAliasWasSet=1
    fi
fi

echo -e "Starting build"
echo -e "----------------\n"

# Define output and Dockerfile path variables
scriptDir=$(dirname "${BASH_SOURCE[0]}")
outDir="${scriptDir}/out"
outFilePath="${outDir}/fedora-latest.tar"
dockerFilePath="${scriptDir}/Dockerfile"

# Remove the existing output directory if it already exists.
if [ -d "${outDir}" ]
then
    echo -e "- Output directory already exists."
    echo -e "\t- Deleting..."
    rm -rf "${outDir}"
fi

# Create a new output directory.
echo -e "- Creating output directory at '${outDir}'."
mkdir "${outDir}"

# Remove any existing Fedora images.
echo -e "- Removing any previously pulled Fedora images."
localFedoraImgs=$(docker images | grep -Po '^docker\.io\/library\/fedora\s+(.+?)\s+\K([a-z0-9]{12})' | sort --unique)
for item in $( echo "${localFedoraImgs[@]}" )
do
    echo -e "\t- Removing Image ID: ${item}"
    docker rmi "${item}" --force > /dev/null
done

# Pull the latest Fedora image from DockerHub.
echo -e "- Pulling the latest Fedora image from DockerHub."
echo -e "\n------- 'docker pull' output -------"
docker pull docker.io/library/fedora:latest
echo -e "------------------------------------\n"

# Run the image build.
echo -e "- Building the image."
echo -e "\n------- 'docker build' output -------"
docker build --tag wsl2-fedora "${scriptDir}"
echo -e "--------------------------------------\n"

# Start a container from the built image and get it's ID.
docker run -t --name=wsl2-fedora wsl2-fedora:latest echo "Hello world!"

containerId=$(docker container ls -a | grep -i wsl2-fedora | awk '{print $1}')

# Export the container to the output path.
echo -e "- Exporting container to: ${outFilePath}"
docker export $containerId > $outFilePath

# Cleanup container and image resources.
echo -e "- Cleaning up..."
docker container stop $containerId > /dev/null
docker container rm $containerId > /dev/null
builtImages=$(docker images | grep -Po '^wsl2-fedora\s+(.+?)\s+\K([a-z0-9]{12})' | sort --unique)
for item in $( echo "${builtImages[@]}" )
do
    echo -e "\t- Removing Image ID: ${item}"
    docker rmi "${item}" --force > /dev/null
done

# Remove the temporary alias, if it was set.
if [[ $dockerAliasWasSet -eq 1 ]]
then
    echo -e "\t- A temporary alias for docker was set during the script."
    echo -e "\t\t- Removing alias for podman to resolve to docker."
    unalias docker
fi

echo -e "\nBuild complete."
echo -e "----------------\n"
echo -e "Output file: ${outFilePath}"