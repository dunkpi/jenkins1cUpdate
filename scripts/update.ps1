# Скрипт блокирования\разброкирования РЗ для ИБ

# --- Ввод параметров подключения ---
Param (
    [Parameter()][string]$platform1c = '',
    [Parameter()][string]$server1c = '',
    [Parameter()][string]$infobase = '',
    [Parameter()][string]$user = '',
    [Parameter()][string]$passw = '',
    [Parameter()][string]$backupDir = '',
    [Parameter()][string]$permCode = ''
)
# --- Рабочая часть скрипта ---
try {
    $connectionString ='DESIGNER /S' + $server1c + '\' + $infobase + ' /N' + $user + ' /P' + $passw + ' /UC' + $permCode + ' /Out' + $backupDir + '\load_' + $infobase + '_' + (Get-Date -UFormat '%Y%m%d_%H%M') + '.txt /DisableStartupMessages /LoadCfg ' + $backupDir + '\update.cf'
    & $platform1c $connectionString | Out-Null
    $connectionString ='DESIGNER /S' + $server1c + '\' + $infobase + ' /N' + $user + ' /P' + $passw + ' /UC' + $permCode + ' /Out' + $backupDir + '\update_' + $infobase + '_' + (Get-Date -UFormat '%Y%m%d_%H%M') + '.txt /DisableStartupMessages /UpdateDBCfg -Server -Dynamic'
    & $platform1c $connectionString | Out-Null
} catch {
    throw $_.Exception.Message
}