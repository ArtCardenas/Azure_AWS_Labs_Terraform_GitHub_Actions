$toolsPath = Join-Path $env:USERPROFILE "tools"
$scriptFileName = "Install-TerraformToolsForWindows.ps1"
$scriptPath = Join-Path $toolsPath $scriptFileName
New-Item -ItemType "file" $scriptPath -Force | Out-String | Write-Verbose
(Invoke-WebRequest "https://raw.githubusercontent.com/Azure/infrastructure-as-code-utilities/refs/heads/main/terraform-bootstrap/$scriptFileName").Content | Out-File $scriptPath -Force
Invoke-Expression "$scriptPath -toolsPath `"$toolsPath`""
