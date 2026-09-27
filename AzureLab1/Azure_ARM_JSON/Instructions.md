## Bash - Resource group scope:

# log in (if needed)
az login

# validate
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file template.json \
  --parameters @parameters.json

# deploy
az deployment group create \
  --resource-group myResourceGroup \
  --template-file template.json \
  --parameters @parameters.json \
  --name myDeploymentName


# PowerShell -  Resource group scope:

# sign in
Connect-AzAccount

# validate
Test-AzResourceGroupDeployment -ResourceGroupName 'myResourceGroup' `
  -TemplateFile 'template.json' -TemplateParameterFile 'parameters.json'

Test-AzResourceGroupDeployment -ResourceGroupName '1-5a60023a-playground-sandbox' `
  -TemplateFile 'vNet.json' 


# deploy
New-AzResourceGroupDeployment -ResourceGroupName 'myResourceGroup' `
  -TemplateFile 'template.json' -TemplateParameterFile 'parameters.json' `
  -Name 'myDeploymentName'

New-AzResourceGroupDeployment -ResourceGroupName '1-5a60023a-playground-sandbox' `
  -TemplateFile 'vNet.json' -Name 'ArtDeployment_1'

###----------------------------------------------------------------------------------
## Bash - Subscription scope:

az deployment sub create \
  --location eastus \
  --template-file template.json \
  --parameters @parameters.json \
  --name mySubDeployment

### Powershell
New-AzSubscriptionDeployment -Location 'eastus' `
  -TemplateFile 'template.json' -TemplateParameterFile 'parameters.json' `
  -Name 'mySubDeployment'





# Notes:

### Use --parameters key1=value1 or --parameters @parameters.json.
### az deployment group validate returns errors without creating resources.
### Azure PowerShell (Az module)
