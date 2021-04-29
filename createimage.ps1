# createimage_n_upload.ps1
# created by hyuk@microsoft.com
# input cvs file has list of "sysprep"ed VMs. Use this powershell script For each "sysprep"ed VM to generalized create image, and upload it to Shared Image Gallery as Image definition


Param (
    [Parameter(Mandatory=$true)]
    $inputfile
)

$VMs = Import-CSV $inputfile 

$counter = 0
Foreach ($VM in $VMs){

    $rg = Get-AzResourceGroup -Name $VM.RESOURCE_GROUP_VM
    $vmname = $VM.VMNAME

    Write-Host "[$vmname] Stopping ..."
    Stop-AzVM  -ResourceGroupName $VM.RESOURCE_GROUP_VM -Name $vmname -Force

    Write-Host "[$vmname] Generalizing ..."
    Set-AzVM  -ResourceGroupName $VM.RESOURCE_GROUP_VM  -Name $vmname -Generalized

    $vmObj = Get-AzVM -Name $vmname -ResourceGroupName $VM.RESOURCE_GROUP_VM

    # Create the VM image configuration based on the source VM
    $image = New-AzImageConfig -Location $rg.Location -SourceVirtualMachineId $vmObj.ID 

    # Remove last 6 characters(p-test)
    $length = $vmname.length
    $imageName = $vmname.substring(0, $length - 6) + "Z"

    Write-Host "[$vmname] Create Azure Image[$imageName]"
    $myImage = New-AzImage -Image $image -ImageName $imageName -ResourceGroupName $VM.RESOURCE_GROUP_IMAGE

    Write-Host "[$vmname] Image[$imageName] creation completed. Removing origin VM(NoWait)..."

    Remove-AzVM -ResourceGroupName $VM.RESOURCE_GROUP_VM -Name $vmname -Force -NoWait

    $counter++
}

Write-Host "Total $counter Images creation completed."
