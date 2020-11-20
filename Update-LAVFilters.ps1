$sourceUrl = "https://files.1f0.de/lavf/nightly/"
$sourceTempfile = $env:TEMP + "\tempLAVFilters.exe"
$targetFolder="C:\Program Files (x86)\LAV Filters"
$downloadVersions = @()
$downloadHref = @()



function Test-IsElevated {
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        return $true
    } else {
        return $false
    }
}


Function Test-IsFileLocked {
    [cmdletbinding()]
    Param (
        [parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('FullName','PSPath')]
        [string[]]$Path
    )
    Process {
        ForEach ($Item in $Path) {
            #Verify that this is a file and not a directory
            If ([System.IO.File]::Exists($Item)) {
                Try {
                    $FileStream = [System.IO.File]::Open($Item,'Open','Write')
                    $FileStream.Close()
                    $FileStream.Dispose()
                    $IsLocked = $False
                } Catch [System.UnauthorizedAccessException] {
                    $IsLocked = 'AccessDenied'
                } Catch {
                    $IsLocked = $True
                }
                [pscustomobject]@{
                    File = $Item
                    IsLocked = $IsLocked
                }
            } else {
                [pscustomobject]@{
                    File = $Item
                    IsLocked = 'FileDoesNotExistOrNoFullFilePath'
                }
            }
        }
    }
}

clear-host
write-host "Updating LAVFilters to the most recent version"
write-host "------------------------------------------------------------"
write-host

write-host "Checking for elevated permissions"
if (Test-IsElevated) {
    write-host "  Script running elevated."
} else {
    write-host "  Script not running elevated, exiting."
    Start-Sleep -s 10
    exit 1
}
write-host

write-host "Getting latest file version."
((Invoke-WebRequest -URI $sourceUrl).Links | Where-Object {$_.href -like "LAVFilters-*.exe"}).href | ForEach-Object {
    $downloadVersions += [System.Version]::Parse((($_.replace('LAVFilters-','')).replace('.exe','')).replace('-','.'))
    $downloadHref += $_
}

$downloadVersion = ($downloadVersions | Measure-Object -Maximum).Maximum
$sourceUrl = $sourceurl + '\' + $downloadHref[$downloadVersions.IndexOf(($downloadVersions | Measure-Object -Maximum).Maximum)]


write-host
write-host "Getting version information."
$InstalledVersion = [System.Version]::Parse((get-itemproperty -path "hklm:\software\wow6432node\microsoft\windows\currentversion\uninstall\lavfilters_is1").DisplayVersion.replace('-','.'))

# $DownloadVersion = [System.Version]::Parse(([System.Diagnostics.FileVersionInfo]::GetVersionInfo($sourceTempfile)).ProductVersion)

write-host "  Version available for download: " $DownloadVersion
write-host "  Version of installed file:      " $InstalledVersion

write-host
if ($DownloadVersion -gt $InstalledVersion) {
    echo "Newer version available, download and install it."
    write-host "  Downloading file."
    if (((Get-ChildItem $targetFolder -Recurse -Force | where-object {$_.PSIsContainer -ne $true} | Test-IsFileLocked | where {$_.IsLocked -ne $false}).count) -ne 0) {
        write-host ("  At least one file in or below """ + $targetFolder + """ is locked, exiting.")
        Start-Sleep -s 10
        exit 1
    } else {
        (New-Object System.Net.WebClient).DownloadFile($sourceUrl, $sourceTempfile)
    }

    if (!(test-path $sourceTempfile)) {
        write-host "    Problem downloading file, exiting."
        Start-Sleep -s 10
        exit 1
    }
    if (((Get-ChildItem $targetFolder -Recurse -Force | where-object {$_.PSIsContainer -ne $true} | Test-IsFileLocked | where {$_.IsLocked -ne $false}).count) -ne 0) {
        write-host ("  At least one file in or below """ + $targetFolder + """ is locked, exiting.")
        Start-Sleep -s 10
        exit 1
    } else {
        $p = Start-Process $sourceTempfile -ArgumentList '/silent', '/norestart', '/nocloseapplications','/norestartapplications', '/type=full' -wait -NoNewWindow -PassThru
        write-host ("  Exit code: " + $p.ExitCode)
    }
} elseif ($DownloadVersion -eq $InstalledVersion) {
    echo "Versions of installed and downloadable file match, nothing to do."
} else {
    echo "Version of downloadable file is lower than installed version, nothing to do."
}


if ((test-path $sourceTempfile)) {
    remove-item $sourceTempfile -force
}

Start-Sleep -s 10