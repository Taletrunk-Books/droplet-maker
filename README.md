# Project Title

This project contains two scripts: `make-droplet.sh` and `setup.sh`. The `make-droplet.sh` script sets up a new droplet with Docker and GitHub CLI pre-installed. The `setup.sh` script is a primitive Git deployment script that sets up an SSH connection, clones a repository, and manages Docker containers.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- A Unix-like operating system: macOS, Linux, BSD. On Windows: WSL is preferred, but cygwin or msys also mostly work.
- `bash`, `curl`, `sudo`

### Droplet Maker in REMOTE MACHINE

The `make-droplet.sh` script sets up a new droplet with Docker and GitHub CLI pre-installed. To use it, follow the instructions in `make-droplet.md`.

### Primitive Git Deployment Script IN PROJECT REPOSITORY

The `setup.sh` script is a primitive Git deployment script. To use it, copy it to the repository you want to deploy, and follow the instructions in `setup-readme.md`.
