# Ft_Onion42
My approach to ciber-security 42 bootcamp ft_onion project

## Description
This project goal is building a service for a Web Server into the Tor network using Docker.

I included an extra script for building the service, called `init.sh`

The educational value of this project is understanding the Tor network functioning, as well as docker container deployment using shell scripting

## Usage

### Set Up

To set up the `init.sh` script you must configure the path for your ssh_public_key to use, so you can log into the docker container via ssh, using public_key authentication. Additionally, you can change the log file path to see any logs about the building process for debugging purposes. Both variables are at the top of the script

### Building

After setting the script up, in order to build the docker container and the service, it's neccesary to run `init.sh`