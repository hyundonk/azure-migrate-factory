Param(
    [parameter(Mandatory=$true)]
    $CsvFilePath
)

$ErrorActionPreference = "Stop"

$scriptsPath = $PSScriptRoot
if ($PSScriptRoot -eq "") {
    $scriptsPath = "."
}

. "$scriptsPath\asr_logger.ps1"
. "$scriptsPath\asr_csv_processor.ps1"

$logger = New-AsrLoggerInstance -CommandPath $PSCommandPath

$ResourceGroupName=""
$TestVirtualNetworkName=""

$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
$logger.LogTrace("Resource Group Name: $($ResourceGroup.ResourceGroupName)")

$MigrateProject = Get-AzMigrateProject -Name $MigrationProjectName -ResourceGroupName $ResourceGroup.ResourceGroupName
$logger.LogTrace("Migration Project Name: $($MigrateProject.Name)")

$TestVirtualNetwork = Get-AzVirtualNetwork -Name $TestVirtualNetworkName
$logger.LogTrace("Test Virtual Network Name: $($TestVirtualNetwork.Name)")

Function ProcessItemImpl($processor, $csvItem, $reportItem) {
    $reportItem | Add-Member NoteProperty "TestFailoverJobId" $null
    $reportItem | Add-Member NoteProperty "TestFailoverState" $null
    $reportItem | Add-Member NoteProperty "TestFailoverStateDescription" $null

    $processor.Logger.LogTrace("VMNAME: $($csvItem.VMNAME)")

    $ReplicatingServer = Get-AzMigrateServerReplication -ProjectName $MigrateProject.Name -ResourceGroupName $ResourceGroup.ResourceGroupName -MachineName $csvItem.VMNAME

    $UpdateJob = Set-AzMigrateServerReplication -InputObject $ReplicatingServer -TargetVMSize Standard_F8s_v2 -TargetVMName $csvItem.VMNAME

    # Track job status to check for completion
    while (($UpdateJob.State -eq 'InProgress') -or ($UpdateJob.State -eq 'NotStarted')){
        #If the job hasn't completed, sleep for 1 seconds before checking the job status again
        sleep 1;
        $UpdateJob = Get-AzMigrateJob -InputObject $UpdateJob
    }
    # Check if the Job completed successfully. The updated job state of a successfully completed job should be "Succeeded".
    $logger.LogTrace("VM size update job finished: $($UpdateJob.State)")

    
    $ReplicatingServer = Get-AzMigrateServerReplication -ProjectName $MigrateProject.Name -ResourceGroupName $ResourceGroup.ResourceGroupName -MachineName $csvItem.VMNAME

    if ($ReplicatingServer.MigrationState -eq 'Replicating') {
      $logger.LogTrace("Replicating Server: $($ReplicatingServer.MachineName) in $($ReplicatingServer.MigrationState), $($ReplicatingServer.MigrationStateDescription) start Test Migration Job")
      
      $LastRecoveryPointReceived = $($ReplicatingServer.ProviderSpecificDetail).LastRecoveryPointReceived
      $logger.LogTrace("LastRecoveryPointReceived: $LastRecoveryPointReceived")
  
      $TestMigrationJob = Start-AzMigrateTestMigration -InputObject $ReplicatingServer -TestNetworkID $TestVirtualNetwork.Id
      sleep 1
      $TestMigrationJob = Get-AzMigrateJob -InputObject $TestMigrationJob
      $logger.LogTrace("Test Migration Job for $($ReplicatingServer.MachineName) in $($TestMigrationJob.State)")

    }
    else {
      $logger.LogTrace("Replicating Server: $($ReplicatingServer.MachineName) in $($ReplicatingServer.MigrationState), $($ReplicatingServer.MigrationStateDescription) Skipping Test Migration Job")
    }
}

Function ProcessItem($processor, $csvItem, $reportItem)
{
    try {
        ProcessItemImpl $processor $csvItem $reportItem
    }
    catch {
        $exceptionMessage = $_ | Out-String
        $processor.Logger.LogError($exceptionMessage)
        throw
    }
}

$processor = New-CsvProcessorInstance -Logger $logger -ProcessItemFunction $function:ProcessItem
$processor.ProcessFile($CsvFilePath)

