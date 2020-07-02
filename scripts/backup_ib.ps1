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
    $connectionString ='DESIGNER /S' + $server1c + '\' + $infobase + ' /N' + $user + ' /P' + $passw + ' /UC' + $permCode + ' /Out' + $backupDir + '\backup_' + $infobase + '_' + (Get-Date -UFormat '%Y%m%d_%H%M') + '.txt -NoTruncate /DumpIB' + $backupDir + '\' + $infobase + '_' + (Get-Date -UFormat '%Y%m%d_%H%M') + '.dt'
    & $platform1c $connectionString | Out-Null
} catch {
    throw $_.Exception.Message
}