<# 
    .SYNOPSIS
        Builds a Hornbill Power Virtual Agent chatbot for import as a Solution into a Power Apps Environment
    .DESCRIPTION
        Builds a Hornbill Power Virtual Agent chatbot for import as a Solution into a Power Apps Environment.
    .EXAMPLE
        PS> ./BuildPVAPackage.ps1
    .LINK
        https://wiki.hornbill.com/index.php?title=Teams_Power_Virtual_Agent
#>
Write-Host "** Hornbill Power Automate Solution Build Tool **"
Write-Host "`nPreparing content, please wait..."
Remove-Item PVAContent -Recurse -ErrorAction Ignore
Expand-Archive -Path HornbillPVASolution.Zip -DestinationPath PVAContent

[xml]$SolutionXML = Get-Content -Path 'PVAContent/solution.xml'
$PVAUniqueName = $SolutionXML.ImportExportXml.SolutionManifest.UniqueName
$PVADisplayName = $SolutionXML.ImportExportXml.SolutionManifest.LocalizedNames.LocalizedName.description
$PVAVersion = $SolutionXML.ImportExportXml.SolutionManifest.Version
$PVAVersionUS = $PVAVersion -replace "\.", "_"

Write-Host "`nContent prepared, building $($PVADisplayName) v$($PVAVersion)."
Write-Host ""
Write-Host "Please provide the following:"
Write-Host ""

## Get Inputs
# Instance Details
$InstanceID = Read-Host "The ID of your Hornbill instance"
$APIKey = Read-Host "The API key for your Teams PVA account on your Hornbill instance"
$UserUPN = Read-Host "The field in your Hornbill instance user records that holds the UPN (userId / employeeId / loginId / attrib1 / ... / attrib8)"

#Topic - I Need Help
try {
    Write-Host "`nTopic - I Need Help:"
    [Int]$IssueServiceID = Read-Host "Service ID [integer], 0 to log against no Service"
    [Int]$IssueCatalogItemID = Read-Host "Catalog Item ID [integer], 0 to log against no Catalog Item"
} catch {
    Write-Error $_.Exception.Message
    Exit
}

# Topic - New Starter
Write-Host "`nTopic - New Starter:"
$NewStarterEnabled = Read-Host "Enabled (yes/no)"
[Int]$NewStarterServiceID = 0
[Int]$NewStarterCatalogItemID = 0
[Bool]$NewStarterEnabledBool = $False
if ("yes" -eq $NewStarterEnabled.ToLower()) {
    # New Starter Topic Enable
    try {
        $NewStarterEnabledBool = $True
        $NewStarterServiceID = Read-Host "Service ID [integer], 0 to log against no Service"
        $NewStarterCatalogItemID = Read-Host "Catalog Item ID [integer], 0 to log against no Catalog Item"
    } catch {
        Write-Error $_.Exception.Message
        Exit
    }
} elseif ("no" -eq $NewStarterEnabled.ToLower()) {
    # Do nothing
} else {
    Write-Error "Value needs to be yes or no"
    Exit
}

# Topic - Leaver
Write-Host "`nTopic - Leaver:"
$LeaverEnabled = Read-Host "Enabled (yes/no)"
[Int]$LeaverServiceID = 0
[Int]$LeaverCatalogItemID = 0
[Bool]$LeaverEnabledBool = $False
if ("yes" -eq $LeaverEnabled.ToLower()) {
    # New Starter Topic Enable
    try {
        $LeaverEnabledBool = $True
        $LeaverServiceID = Read-Host "Service ID [integer], 0 to log against no Service"
        $LeaverCatalogItemID = Read-Host "Catalog Item ID [integer], 0 to log against no Catalog Item"
    } catch {
        Write-Error $_.Exception.Message
        Exit
    }
} elseif ("no" -eq $LeaverEnabled.ToLower()) {
    # Do nothing
} else {
    Write-Error "Value needs to be yes or no"
    Exit
}

# Topic - Password Reset
Write-Host "`nTopic - Password Reset:"
$PasswordResetEnabled = Read-Host "Enabled (yes/no)"
[Int]$PasswordResetServiceID = 0
[Int]$PasswordResetCatalogItemID = 0
[Bool]$PasswordResetEnabledBool = $False
if ("yes" -eq $PasswordResetEnabled.ToLower()) {
    # New Starter Topic Enable
    try {
        $PasswordResetEnabledBool = $True
        $PasswordResetServiceID = Read-Host "Service ID [integer], 0 to log against no Service"
        $PasswordResetCatalogItemID = Read-Host "Catalog Item ID [integer], 0 to log against no Catalog Item"
    } catch {
        Write-Error $_.Exception.Message
        Exit
    }
} elseif ("no" -eq $PasswordResetEnabled.ToLower()) {
    # Do nothing
} else {
    Write-Error "Value needs to be yes or no"
    Exit
}

## Process Instance ID & API Key
Write-Output "`nProcessing Solution Hornbill Instance Details..."
try {
    $FilePath = 'PVAContent/botcomponents/new_topic_ec37b06cec7b4671bbc989cd7b0945c5_ba7b967c97ba4c39bca58a8bb6a72d59_conversationstart/content.json'

    # Read JSON from file
    $ComponentJSON = Get-Content $FilePath -raw | ConvertFrom-Json
    
    # Set Instance ID
    $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq 'aab68ff4-ab08-4e47-9735-eac5404b2176'){$_.inputParameterVariableIdMap.text=$InstanceID.ToLower()}}
    $ComponentJSON.actionDefinitions | % {if($_.id -eq 'a1c05af8-6ac2-411b-9099-7088acaa78ad'){$_.bodyContent='{"text":"'+$InstanceID.ToLower()+'"}'}}
    
    # Set API Key
    $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '066b5977-290d-4f31-a2ea-1669c9b86c24'){$_.inputParameterVariableIdMap.text=$APIKey}}
    $ComponentJSON.actionDefinitions | % {if($_.id -eq 'd1e5b56e-a0b6-4f6d-8cb6-5f82fca116d3'){$_.bodyContent='{"text":"'+$APIKey+'"}'}}

    # Set User Field
    $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '335ce7a6-aa07-469d-acf0-f83fa38f9b71'){$_.inputParameterVariableIdMap.text=$UserUPN}}
    $ComponentJSON.actionDefinitions | % {if($_.id -eq '0a1c5383-19d9-4b43-a3a9-3935958c4d2f'){$_.bodyContent='{"text":"'+$UserUPN+'"}'}}
    
    # Write JSON back to file
    $ComponentJSON | ConvertTo-Json -depth 32| set-content $FilePath
} catch {
    Write-Error "Error processing InstanceID & API Key Data: $($_.Exception.Message)"
    Exit
}
Write-Output "Completed Solution Hornbill Instance Details"

## Process Topic - I Need Help
Write-Output "`nProcessing Topic - I Need Help..."
try {
    $FilePath = 'PVAContent/botcomponents/new_topic_e7db7bd92cfc4ee0876899aa093c5873/content.json'

    # Read JSON from file
    $ComponentJSON = Get-Content $FilePath -raw | ConvertFrom-Json

    # Set Service ID
    $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '5c595a37-3ea4-4cc9-bfb3-4424d4cbf104'){$_.inputParameterVariableIdMap.number=$IssueServiceID}}
    
    # Set Catalog Item ID
    $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '3a1c8753-82e9-4a13-b8a9-8ff7a53a3a4e'){
        $_.inputParameterVariableIdMap.number=$IssueCatalogItemID
        $_
        }}
    
    # Write JSON back to file
    $ComponentJSON | ConvertTo-Json -depth 32| set-content $FilePath
} catch {
    Write-Error "Error processing Topic - I Need Help Data: $($_.Exception.Message)"
    Exit
}
Write-Output "Completed Topic - I Need Help"

## Process Topic - New Starter
if ($True -eq $NewStarterEnabledBool) {
    Write-Output "`nProcessing Topic - New Starter..."
    $TopicUID = "new_topic_96209aa1caa6413598868b281fab0305"
    $FilePath = "PVAContent/botcomponents/$($TopicUID)/content.json"
    try {
        # Read JSON from file
        $ComponentJSON = Get-Content $FilePath -raw | ConvertFrom-Json

        # Enable New Starter Topic Trigger
        $ComponentJSON.intents | % {if($_.id -eq $TopicUID){$_.isTriggeringEnabled=$True}}

        # Set Service ID
        $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '4a16e5c8-a76a-45e8-803b-09c9a4ccab5d'){$_.inputParameterVariableIdMap.number=$NewStarterServiceID}}
        
        # Set Catalog Item ID
        $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '41a0d9c8-092a-48f7-a9d6-64bc3ce16d6e'){$_.inputParameterVariableIdMap.number=$NewStarterCatalogItemID}}
        
        # Write JSON back to file
        $ComponentJSON | ConvertTo-Json -depth 32| set-content $FilePath
    } catch {
        Write-Error "Error processing Topic - New Starter: $($_.Exception.Message)"
        Exit
    }
    Write-Output "Completed Topic - New Starter"
}

## Process Topic - Leaver
if ($True -eq $LeaverEnabledBool) {
    Write-Output "`nProcessing Topic - Leaver..."
    $TopicUID = "new_topic_b6b784d775b449e5b2edb886638a5b06"
    $FilePath = "PVAContent/botcomponents/$($TopicUID)/content.json"
    try {
        # Read JSON from file
        $ComponentJSON = Get-Content $FilePath -raw | ConvertFrom-Json

        # Enable Leaver Topic Trigger
        $ComponentJSON.intents | % {if($_.id -eq $TopicUID){$_.isTriggeringEnabled=$True}}

        # Set Service ID
        $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '8d5fc718-7686-4417-a9e1-24e6f421b2f7'){$_.inputParameterVariableIdMap.number=$LeaverServiceID}}
        
        # Set Catalog Item ID
        $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq 'abcfb40c-acd1-4a9d-a984-5d13141cebc1'){$_.inputParameterVariableIdMap.number=$LeaverCatalogItemID}}
        
        # Write JSON back to file
        $ComponentJSON | ConvertTo-Json -depth 32| set-content $FilePath
    } catch {
        Write-Error "Error processing Topic - Leaver: $($_.Exception.Message)"
        Exit
    }
    Write-Output "Completed Topic - Leaver"
}

## Process Topic - Password Reset
if ($True -eq $PasswordResetEnabledBool) {
    Write-Output "`nProcessing Topic - Password Reset..."
    $TopicUID = "new_topic_1eb79759048b47be8a85d9bf757d8f93"
    $FilePath = "PVAContent/botcomponents/$($TopicUID)/content.json"
    try {
        # Read JSON from file
        $ComponentJSON = Get-Content $FilePath -raw | ConvertFrom-Json

        # Enable Password Reset Topic Trigger
        $ComponentJSON.intents | % {if($_.id -eq $TopicUID){$_.isTriggeringEnabled=$True}}

        # Set Service ID
        $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq '50d7d902-965d-4dde-93a7-ce97a32d355b'){$_.inputParameterVariableIdMap.number=$PasswordResetServiceID}}
        
        # Set Catalog Item ID
        $ComponentJSON.dialogs[0].actionNodes | % {if($_.id -eq 'f0c79dac-eb0a-4145-acb9-6d26b2c124d7'){$_.inputParameterVariableIdMap.number=$PasswordResetCatalogItemID}}
        
        # Write JSON back to file
        $ComponentJSON | ConvertTo-Json -depth 32| set-content $FilePath
    } catch {
        Write-Error "Error processing Topic - PasswordReset: $($_.Exception.Message)"
        Exit
    }
    Write-Output "Completed Topic - Password Reset"
}

## Zip the package up
Write-Output "`nBuilding Solution, please wait..."
$SolutionPackageFile = "$($PVAUniqueName)_v$($PVAVersionUS).zip"
Get-ChildItem -Path "PVAContent/" | Compress-Archive -DestinationPath $SolutionPackageFile -Force

## Delete the WIP folder & content
Write-Output "Cleaning up folder, please wait..."
Remove-Item PVAContent -Recurse

Write-Output "`n"
Write-Output "* Instance ID: $($InstanceID)"
Write-Output "* API Key: $($APIKey)"
Write-Output "* Topic - I Need Help; Service ID: $($IssueServiceID)"
Write-Output "* Topic - I Need Help; Catalog Item ID: $($IssueCatalogItemID)"
Write-Output "* Topic - New Starter; Enabled: $($NewStarterEnabled)"
if ($True -eq $NewStarterEnabledBool) {
    Write-Output "* Topic - New Starter; Service ID: $($NewStarterServiceID)"
    Write-Output "* Topic - New Starter; Catalog Item ID: $($NewStarterCatalogItemID)"
}
Write-Output "* Topic - Leaver; Enabled: $($LeaverEnabled)"
if ($True -eq $LeaverEnabledBool) {
    Write-Output "* Topic - Leaver; Service ID: $($LeaverServiceID)"
    Write-Output "* Topic - Leaver; Catalog Item ID: $($LeaverCatalogItemID)"
}
Write-Output "* Topic - Password Reset; Enabled: $($PasswordResetEnabled)"
if ($True -eq $PasswordResetEnabledBool) {
    Write-Output "* Topic - Password Reset; Service ID: $($PasswordResetServiceID)"
    Write-Output "* Topic - Password Reset; Catalog Item ID: $($PasswordResetCatalogItemID)"
}

Write-Output "`nSolution Build Complete! Your solution for import is: $($SolutionPackageFile)`n"