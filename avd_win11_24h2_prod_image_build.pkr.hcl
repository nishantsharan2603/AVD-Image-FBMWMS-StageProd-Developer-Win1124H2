packer {
  required_version = ">= 1.9.0"

  required_plugins {
    azure = {
      version = ">= 1.8.0"
      source  = "github.com/hashicorp/azure"
    }
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "subscription_id" {
        }
variable "tenant_id" {
        }
variable "client_id" {
        }
variable "client_secret" {
        }

source "azure-arm" "win11_24h2_avd_hsud" {
    subscription_id     = var.subscription_id
    tenant_id           = var.tenant_id
    client_id           = var.client_id
    client_secret       = var.client_secret
    os_type         = "Windows"
    image_publisher = "microsoftwindowsdesktop"
    image_offer     = "office-365"
    image_sku       = "win11-24h2-avd-m365"
    image_version   = "latest"
    vm_size         = "Standard_E8ds_v5"
    os_disk_size_gb = 127
    communicator   = "winrm"
    winrm_use_ssl  = true
    winrm_insecure = true
    winrm_timeout  = "10m"
    winrm_username = "packer"
    build_resource_group_name = "rgazweuavdpackerbuild01"
    #build_timeout_in_minutes = 960
  
    shared_image_gallery_destination {
        subscription        = var.subscription_id
        resource_group      = "rgazweuavdprodacg01"
        gallery_name        = "acgazweuavdprod02"
        image_name          = "azure_windows_11_baseos_avd_hsud_24h2"
        image_version       = "19.11.2025"
        replication_regions = ["westeurope","eastasia","eastus2"]
    }

    azure_tags = {
        AVDAZServices= "AVD Components"
        Environment = "Production"
        Owner       = "AVDTeam"
    }
}

build {
    name    = "AVD_Win11_24H2_Image_Build"
    sources = ["source.azure-arm.win11_24h2_avd_hsud"]
    #timeout = "16h"
/*
    provisioner "powershell" {
        inline = [
        "New-Item -Path 'C:\\AVDImage' -ItemType Directory -Force | Out-Null"
        ]
    }

    provisioner "powershell" {
        inline = [
        #"Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2024-03-27/InstallLanguagePacks.ps1' -OutFile 'C:\\AVDImage\\installLanguagePacks.ps1'",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_EnableFeature_DotNet3.5.ps1' -OutFile 'C:\\AVDImage\\AIB_EnableFeature_DotNet3.5.ps1'",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_Install_Updated_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_Install_Updated_Win1124H2.ps1'",
        "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2024-03-27/ConfigureOfficeApps.ps1' -OutFile 'C:\\AVDImage\\OfficeApps.ps1'",
        "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2024-03-27/MultiMediaRedirection.ps1' -OutFile 'C:\\AVDImage\\multiMediaRedirection.ps1'",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_NewTeamsAddinInstall_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_NewTeamsAddinInstall_Win1124H2.ps1'",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_CustomSettings_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_CustomSettings_Win1124H2.ps1'",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_UWPRemoval_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_UWPRemoval_Win1124H2.ps1'",
        "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2024-03-27/WindowsOptimization.ps1' -OutFile 'C:\\AVDImage\\windowsOptimization.ps1'",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_SecurityToolInstallation_Nov.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_SecurityToolInstallation_Nov.ps1'",
        #"Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2024-03-27/AdminSysPrep.ps1' -OutFile 'C:\\AVDImage\\AdminSysPrep.ps1'"
        ]
    }
*/
  ##############################################
  # 1. Install HSUD Applications
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_HSUD_InstallApps.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_HSUD_InstallApps.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_HSUD_InstallApps.ps1"
        ]
        timeout          = "2h"
        valid_exit_codes = [0, 3010]
    }

  ##############################################
  # 2. Multimedia Redirection Setup
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage2'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage2",
        "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2024-03-27/MultiMediaRedirection.ps1' -OutFile 'C:\\AVDImage2\\multiMediaRedirection.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\multiMediaRedirection.ps1 -VCRedistributableLink 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -EnableEdge 'true' -EnableChrome 'true'"
        ]
        timeout          = "2h"
        valid_exit_codes = [0, 3010]
    }
  ##############################################
  # 3. Install New Teams Add-in
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_NewTeamsAddinInstall_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_NewTeamsAddinInstall_Win1124H2.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_NewTeamsAddinInstall_Win1124H2.ps1"
        ]
        timeout          = "2h"
        valid_exit_codes = [0, 3010]
    }

  ##############################################
  # 4. Apply Custom AVD Settings
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_HSUD_CustomSettings.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_HSUD_CustomSettings.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_HSUD_CustomSettings.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }
  ##############################################
  # 5. Remove UWP Apps
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_UWPRemoval_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_UWPRemoval_Win1124H2.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_UWPRemoval_Win1124H2.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }
  ##############################################
  # 6. Windows Optimization
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage3'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage3",
        "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2024-03-27/WindowsOptimization.ps1' -OutFile 'C:\\AVDImage3\\windowsOptimization.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\windowsOptimization.ps1 -Optimizations 'DefaultUserSettings','NetworkOptimizations'"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }
  ##############################################
  # 7. Post-Optimization Windows Updates
  ##############################################
    provisioner "windows-update" {
        search_criteria = "IsInstalled=0"
        filters = [
        "exclude:$_.Title -like '*Preview*'",
        "include:$true"
        ]
        update_limit = 100
    }

  ##############################################
  # 8. Reboot After Optimization
  ##############################################
    provisioner "powershell" {
        inline = [
        "Write-Output 'Rebooting after optimizations...'; Restart-Computer -Force"
        ]
        timeout = "30m"
    }
  ##############################################
  # 9. Disabling Scheduled Task
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_DisableScheduleTask_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_DisableScheduleTask_Win1124H2.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_DisableScheduleTask_Win1124H2.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }
  ##############################################
  # 10. Disabling Unwanted Services
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_DisableServices_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_DisableServices_Win1124H2.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_DisableServices_Win1124H2.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }

  ##############################################
  # 11. Disabling Windows traces
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_DisableWindowsTraces_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_DisableWindowsTraces_Win1124H2.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_DisableWindowsTraces_Win1124H2.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }

  ##############################################
  # 12. Lanman Paramters
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_LanmanParameters.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_LanmanParameters.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_LanmanParameters.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }

  ##############################################
  # 13. App-V Task Schedular
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_ScheduleTaskAppVCaching.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_ScheduleTaskAppVCaching.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_ScheduleTaskAppVCaching.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }
  ##############################################
  # 14. Security Hardening of the Image
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_SecurityHardening_Win1124H2.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_SecurityHardening_Win1124H2.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_SecurityHardening_Win1124H2.ps1"
        ]
        timeout          = "1h"
        valid_exit_codes = [0, 3010]
    }

  ##############################################
  # 15. Install Security Tools
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path = 'C:\\AVDImage'",
        "If(!(Test-Path $path))",
        "{",
        "New-Item -ItemType Directory -Force -Path $path",
        "}",
        "cd C:\\AVDImage",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_SecurityToolInstallation_Nov.ps1' -OutFile 'C:\\AVDImage\\AIB_AVD_SecurityToolInstallation_Nov.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_SecurityToolInstallation_Nov.ps1"
        ]
        timeout          = "2h"
        valid_exit_codes = [0, 3010]
    }

  ##############################################
  # 16. Cleanup Image Build Artifacts
  ##############################################
    provisioner "powershell" {
        inline = [
        "$path1 = 'C:\\AVDImage'",
        "If((Test-Path $path1))",
        "{",
        "Remove-Item -Path $path1 -Recurse -Force -ErrorAction SilentlyContinue",
        "}",

        "$path2 = 'C:\\AVDImage1'",
        "If((Test-Path $path2))",
        "{",
        "Remove-Item -Path $path2 -Recurse -Force -ErrorAction SilentlyContinue",
        "}",

        "$path3 = 'C:\\AVDImage2'",
        "If((Test-Path $path3))",
        "{",
        "Remove-Item -Path $path3 -Recurse -Force -ErrorAction SilentlyContinue",
        "}",

        "$path4 = 'C:\\AVDImage3'",
        "If((Test-Path $path4))",
        "{",
        "Remove-Item -Path $path4 -Recurse -Force -ErrorAction SilentlyContinue",
        "}",

        "cd D:\\",
        "Invoke-WebRequest -Uri 'https://avdweustc03.blob.core.windows.net/source/AIB_AVD_DiskCleanup.ps1' -OutFile 'D:\\AIB_AVD_DiskCleanup.ps1'",
        "Start-Sleep -seconds 30",
        "& .\\AIB_AVD_DiskCleanup.ps1"
        ]
        timeout          = "2h"
        valid_exit_codes = [0, 3010]
    }
  ##############################################
  # 17. Run Admin SysPrep
  ##############################################
    provisioner "powershell" {
        inline = [
            "# NOTE: the following *3* lines are only needed if the you have installed the Guest Agent.",
            "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
            "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
            "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
            "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
        ]
        timeout          = "2h"
        valid_exit_codes = [0, 3010]
    }
}
