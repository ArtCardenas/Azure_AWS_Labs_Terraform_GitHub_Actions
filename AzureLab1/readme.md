### install azure cli
### https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=winget

### close Visual Studio Code and Reopen


az group list --query [].name
az network vnet list --query [].name

###
terraform init
terraform validate
terraform apply -auto-approve