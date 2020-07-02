# Скрипт выбрасывания пользователей из ИБ

# --- Ввод параметров подключения ---
Param (
    [Parameter()][string]$server1c = '',
    [Parameter()][string]$port1c = '',
    [Parameter()][string]$infobase = '',
    [Parameter()][string]$user = '',
    [Parameter()][string]$passw = ''
)
# --- Рабочая часть скрипта ---
try {
    $V83Com=New-Object -ComObject "V83.ComConnector"
    $ServerAgent = $V83Com.ConnectAgent($server1c + ":$port1c")
} catch {
    throw $_.Exception.Message
}
$Clusters = $ServerAgent.GetClusters()
$Cluster = $Clusters[0]
$ServerAgent.Authenticate($Cluster, $user, $passw)
$WorkingProcesses = $ServerAgent.GetWorkingProcesses($Cluster);
$CurrentWorkingProcess = $V83Com.ConnectWorkingProcess("tcp://"+$server1c+":" + $WorkingProcesses[0].MainPort)
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
    # Получаем список сессий кластера и прерываем их
     foreach ($CurrCluster in $Clusters) {
        $Sessions = $ServerAgent.GetSessions($CurrCluster)
        if (!($Sessions.Count -eq 0))
        {
            foreach ($Session in $Sessions)
            {
                if ($Session.Infobase.Name -eq $infobase) {
                    write-host 'Reset session' $Session.AppID 'with user' $Session.UserName
                    try {
                        $ServerAgent.TerminateSession($Cluster, $Session)
                    } catch {
                        write-output $_.Exception.Message
                    }
                }
            }
        }
    }
} else {
    write-output 'Infobase $infobase is not found in cluster 1c'
}