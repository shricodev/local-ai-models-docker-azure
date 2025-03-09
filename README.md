# Azure VM with AI Model Deployment

This project automates the process of spinning up a Virtual Machine (VM) on Azure, deploying AI models inside Docker containers, and accessing a web interface to interact with the models using Ollama WebUI.

## Project Structure

```
├── azure/
│   ├── configure-network.sh       # Configures network settings for the VM
│   ├── create-resource-group.sh   # Creates a resource group in Azure
│   ├── create-vm.sh               # Creates a Virtual Machine in Azure
│   └── get-vm-details.sh          # Retrieves public IP of the created VM
├── scripts/
│   ├── access-with-ip.sh          # Limit access to VM to the user public IP
│   ├── deploy-containers.sh       # Deploys Docker containers on the VM
│   ├── run-model.sh               # Runs the AI model inside the container
│   └── setup-vm.sh                # Sets up the VM (install docker) and all
├── .dockerignore
├── .env
├── .env.example
├── .gitignore
├── .vm_details.env                # Stores VM public IP
├── docker-compose.yaml            # Docker Compose configuration for containers
└── README.md
```

## Prerequisites

- Azure CLI installed and configured.
- Docker and Docker Compose installed on your local machine.
- SSH access to the VM.

## Usage

### Step 1: Azure VM Setup

1. **Create a Resource Group**
   Run the following script to create a resource group in Azure:

   ```bash
   bash azure/create-resource-group.sh
   ```

2. **Create a Virtual Machine**
   Use this script to create a VM in the resource group:

   ```bash
   bash azure/create-vm.sh
   ```

3. **Retrieve VM Details**
   After creating the VM, retrieve its details (the public IP):

   ```bash
   bash azure/get-vm-details.sh
   ```

4. **Configure Network**
   Limit the connection to the user public IP

   ```bash
   bash azure/configure-network.sh
   ```

### Step 2: VM Setup and Deployment

1. **Set Up the VM**
   SSH into the VM and run the setup script:

   ```bash
   bash scripts/setup-vm.sh
   ```

2. **Deploy Docker Containers**
   Deploy the necessary Docker containers on the VM:

   ```bash
   bash scripts/deploy-containers.sh
   ```

3. **Run the AI Model**
   Start the AI model inside the Docker container:

   ```bash
   bash scripts/run-model.sh
   ```

4. **Access the Web Interface**
   Use the following script to access the web interface via the VM's IP address:

   ```bash
   bash scripts/access-with-ip.sh
   ```

## Environment Variables

- Update the `.env` file with your Azure credentials and other necessary configurations.
- Use `.env.example` as a template for the `.env` file.

## Notes

- Ensure that the `.vm_details.env` file is generated after running `get-vm-details.sh` as it contains the public IP which other scripts use.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
