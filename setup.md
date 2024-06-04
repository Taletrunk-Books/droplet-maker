# Setup - Primitive Git Deployment Script

## How to Use:

1. Save the script as `setup.sh` in your repository.
2. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```
3. Run the script:
   ```bash
    ./setup.sh
   ```
#### Explanation:

1. **Initial Setup (`setup_config` Function):**

   - Prompts the user for the repository link, SSH key location, SSH username, SSH IP, and the repository folder name.
   - Stores these inputs in a configuration file (`config.cfg`).

2. **SSH Setup and Repository Cloning (`setup_ssh_and_clone` Function):**

   - Reads from the configuration file.
   - Establishes an SSH connection using the provided details.
   - Clones the repository if it doesn't already exist, navigates to the repository folder, and runs Docker Compose to build and start the containers.

3. **Reconnect and Refresh (`reconnect_and_refresh` Function):**

   - Reads from the configuration file.
   - Establishes an SSH connection, navigates to the repository folder, stops the running Docker containers, and then rebuilds and starts them again.

4. **Main Script Logic:**
   - Checks if the configuration file exists.
   - If not, runs the setup process.
   - If it does, performs the refresh process.
