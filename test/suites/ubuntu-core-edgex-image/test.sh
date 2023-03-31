#!/bin/bash -ex

SSH_USER="$USER"
SSH_PORT="8022"

# Install curl on host
snap install curl; echo -e "\n"

# Check status of core services inside of the emulator
ports=(59880 59881 59882)

for port in "${ports[@]}"
do
  ssh "$SSH_USER@localhost" -p $SSH_PORT "curl -s http://localhost:$port/api/v2/ping"; echo -e "\n"
done

# Verify that the security is avaliable as a snap option of edgexfoundry within the emulator
ssh "$SSH_USER@localhost" -p $SSH_PORT "snap get edgexfoundry security -d"; echo -e "\n"

# Check the status of the device-virtual service within the emulator
ssh "$SSH_USER@localhost" -p $SSH_PORT "snap services edgex-device-virtual"; echo -e "\n"


# Access the service endpoints via API Gateway outside of the emulator
curl --insecure --show-err https://localhost:8443/core-data/api/v2/ping; echo -e "\n"

# List snaps and check edgex-config-provider-example is in the list
ssh "$SSH_USER@localhost" -p $SSH_PORT 'snap list'; echo -e "\n"

# Verify that Device Virtual only has one profile, as configured in the config provider
ssh "$SSH_USER@localhost" -p $SSH_PORT 'curl --silent http://localhost:59881/api/v2/deviceprofile/all' | jq '.totalCount'; echo -e "\n" 

# Verify that Device Virtual has the startup message set from the provider
ssh "$SSH_USER@localhost" -p $SSH_PORT 'snap logs -n=all edgex-device-virtual | grep "CONFIG BY EXAMPLE PROVIDER"'; echo -e "\n"

# Query the metadata of Device Virtual from your host machine
curl --insecure --silent --show-err https://localhost:8443/core-data/api/v2/reading/all; echo -e "\n"
