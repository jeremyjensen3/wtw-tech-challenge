# wtw-tech-challenge
This code performs the following actions
* Provisions Ubuntu VM in Azure Cloud using Terraform
* Installs NGINX and configures per assignment specifications using Salt Stack


## Pre-Requisites
* Terraform Installed
* Azure CLI Installed and authenticated ("az login")

## Steps
1. Clone Repository and change to Terraform directory
    ```
    git clone git@github.com:jeremyjensen3/wtw-tech-challenge.git && cd wtw-tech-challenge/terraform
    ```
2. Update changeme.tfvars with public IP and Public SSH key that will be used for administration of VM

3. Initialize Terraform
    ```
    terraform init
    ```
4. Run Terraform Plan, should show 7 resources being created
    ```
    terraform plan -var-file="changeme.tfvars"
    ```  
5. Run Terraform Apply
    ```
    terraform apply -var-file="changeme.tfvars"
    ```
6. Get Public IP of VM instance, we will use this for the next steps
    ```
    az vm show --resource-group WTW-RG --name WTW-VM -d --query [publicIps] --o tsv
    ```
7. SCP Salt directory to remote host for NGINX configuration, substitute public IP
    ```
    scp -r ../salt/ azureuser@X.X.X.X:/home/azureuser
    ```
8. SSH to Remote Server using Public IP
    ```
    ssh azureuser@X.X.X.X
    ```
9. Install and Configure Salt using provided script
    ```
    chmod a+x salt/configure-salt.sh && sudo ./salt/configure-salt.sh
    ```
10. Apply Salt State using Salt Masterless Command
    ```
    sudo salt-call --local state.apply
    ```
    
## Verification
1. Update hosts file on Azure VM and add the following record
    ```
    127.0.0.1 www.example.com
    ```
2. Check that backend (port 3400) is responding  
   Should return a response with the title "Welcome to Example.com!"
    ```
    curl localhost:3400
    ```

3. Check that front-end (port 3200) is responding on www.example.com  
   Should return a response with the title "Welcome to Example.com!"
    ```
    curl www.example.com:3200
    ```
4. Check that front-end returns custom 404 without valid domain
    ```
    curl localhost:3200
    ```

## Clean-Up
1. Run Terraform Destroy to remove all resources
    ```
    terraform destroy -var-file="changeme.tfvars"
    ```
