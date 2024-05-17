# Droplet Maker

This project contains a script for setting up a new droplet with Docker and GitHub CLI pre-installed.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- A Unix-like operating system: macOS, Linux, BSD. On Windows: WSL is preferred, but cygwin or msys also mostly work.
- `bash`, `curl`, `sudo`

### Installation

Clone the repository to your local machine:

```sh
git clone https://github.com/Taletrunk-Books/droplet-maker.git
```

Navigate to the project directory:

```sh
cd droplet-maker
```

Make the script executable:

```sh
chmod +x make-droplet.sh
```

Run the script:

```sh
./droplet-maker.sh
```

## Usage

After running the script, Docker and GitHub CLI will be installed on your machine. You can verify the installations with the following commands:

```sh
docker --version
gh --version
```
