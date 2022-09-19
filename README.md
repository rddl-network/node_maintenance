# RDDL Testnet

## Set up stages

The install.sh script is meant to simplify installation and setup of planetmint networks.

The overall process is staged into the following steps:

1. install_stack: installs all dependencies and the software stack
2. initialize_components: initializes the differenct components
3. get_identities: get the system identites for to be configured
4. configure_components: configures the components with respect to the prior initialization
5. start_services: starts all services
6. verify_status: get the status of all services


## New deployment

Deployment of an new network is done as follows
1. Define a network name and the IPs/names of all nodes in the install.sh file
2. Perform steps 1,2, and 3.
3. MANUALLY Adjust the genesis.json file and copy the public keys (step 3) of all nodes to the file
4. MANUALLY Adjust the config.yaml and define the 'persistent_peers' with the IPs/hostnames and the tendermint address from step 3.
5. Perform step 4
6. MANUALLY login to the hosts and remove their own entry from the .tendermint/config/config.yaml persistent_peer list
7. Perform step 5


## Verification of the working network

Create a transaction, note down the transaction id and verify if the TX is present on all nodes:
1. Create transaction and write down TX-id
2. call ./install.sh <network name> has_tx <tx-id>
3. verify if the TX is available on all nodesg