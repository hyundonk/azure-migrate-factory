$ResourceGroupName=""
$TestVirtualNetworkName=""

$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
Write-Output("Resource Group Name: $($ResourceGroup.ResourceGroupName)")

$MigrateProject = Get-AzMigrateProject -Name $MigrationProjectName -ResourceGroupName $ResourceGroup.ResourceGroupName
Write-Output("Migration Project Name: $($MigrateProject.Name)")

$TestVirtualNetwork = Get-AzVirtualNetwork -Name $TestVirtualNetworkName
Write-Output("Test Virtual Network Name: $($TestVirtualNetwork.Name)")
    
$ReplicatingServer = Get-AzMigrateServerReplication -ProjectName $MigrateProject.Name -ResourceGroupName $ResourceGroup.ResourceGroupName 

foreach ($server in $ReplicatingServer) {
  $initialSeedingProgressPercentage = $($server.ProviderSpecificDetail).InitialSeedingProgressPercentage
  Write-Output("$($server.MachineName), $($server.MigrationState), $($server.MigrationStateDescription), $initialSeedingProgressPercentage")
}


