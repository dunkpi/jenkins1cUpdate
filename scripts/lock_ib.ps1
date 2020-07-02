# Скрипт блокирования\разброкирования РЗ для ИБ

# --- Ввод параметров подключения ---
Param (
    [Parameter()][string]$server1c = '',
    [Parameter()][string]$port1c = '',
    [Parameter()][string]$infobase = '',
    [Parameter()][string]$user = '',
    [Parameter()][string]$passw = '',
    [Parameter()][string]$action = '',
    [Parameter()][string]$permCode = ''
)
# --- Рабочая часть скрипта ---
try {
    $V83Com=New-Object -ComObject 'V83.ComConnector'
    $ServerAgent = $V83Com.ConnectAgent($server1c + ':$port1c')
} catch {
    throw $_.Exception.Message
}
$Clusters = $ServerAgent.GetClusters()
$Cluster = $Clusters[0]
$ServerAgent.Authenticate($Cluster, $user, $passw)
$WorkingProcesses = $ServerAgent.GetWorkingProcesses($Cluster);
$CurrentWorkingProcess = $V83Com.ConnectWorkingProcess('tcp://'+$server1c+':' + $WorkingProcesses[0].MainPort)
$CurrentWorkingProcess.AddAuthentication($user, $passw)
$BaseInfo = $CurrentWorkingProcess.GetInfoBases()
$baseFound = $false
$BaseInfo | ForEach-Object {
    if ($_.Name -eq $infobase) {
        $baseFound = $true
        $Base = $_
    }    
}  
if ($baseFound -eq $true) {
    # Блокируем\разблокируем РЗ
    if ($action -eq 'lock') {
        $Base.ScheduledJobsDenied = $true
        $Base.SessionsDenied = $true
        $Base.PermissionCode = $permCode
        $Base.DeniedMessage = 'Infobase update in progress'
    } else {
        $Base.ScheduledJobsDenied = $false
        $Base.SessionsDenied = $false
        $Base.PermissionCode = ''
        $Base.DeniedMessage = ''
    }
    $CurrentWorkingProcess.UpdateInfoBase($Base)
} else {
    write-output 'Infobase $infobase is not found in cluster 1c'
}