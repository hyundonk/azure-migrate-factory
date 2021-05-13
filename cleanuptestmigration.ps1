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

    if ($ReplicatingServer.TestMigrateState -eq 'TestMigrationSucceeded') {
      $logger.LogTrace("TestMigrated Server: $($ReplicatingServer.MachineName) in $($ReplicatingServer.MigrationState), $($ReplicatingServer.MigrationStateDescription) start Test Migration Clean-up Job")

      $CleanupTestMigrationJob = Start-AzMigrateTestMigrationCleanup -InputObject $ReplicatingServer
      sleep 1
      $CleanupTestMigrationJob = Get-AzMigrateJob -InputObject $CleanupTestMigrationJob
      $logger.LogTrace("Test Migration Clean-up Job for $($ReplicatingServer.MachineName) in $($CleanupTestMigrationJob.State)")

    }
    else {
      $logger.LogTrace("Replicating Server: $($ReplicatingServer.MachineName) in $($ReplicatingServer.TestMigrateState), $($ReplicatingServer.MigrationStateDescription) Skipping Test Migration Clean-up Job")
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

