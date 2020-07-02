# Скрипт блокирования\разброкирования РЗ для ИБ

# --- Ввод параметров подключения ---
Param (
    [Parameter()][string]$platform1c = '',
    [Parameter()][string]$repServer1c = '',
    [Parameter()][string]$repInfobase = '',
    [Parameter()][string]$repUser = '',
    [Parameter()][string]$repPassw = '',
    [Parameter()][string]$repPath = '',
    [Parameter()][string]$user = '',
    [Parameter()][string]$passw = '',
    [Parameter()][string]$backupDir = '',
    [Parameter()][string]$permCode = ''
)
# --- Рабочая часть скрипта ---
try {
    $connectionString ='DESIGNER /S' + $repServer1c + '\' + $repInfobase + ' /N' + $user + ' /P' + $passw + ' /UC' + $permCode + ' /Out' + $backupDir + '\createCF.txt /ConfigurationRepositoryF ' + $repPath + ' /ConfigurationRepositoryN ' + $repUser + ' /ConfigurationRepositoryP ' + $repPassw + ' /ConfigurationRepositoryDumpCfg ' + $backupDir + '\update.cf'
    & $platform1c $connectionString | Out-Null
} catch {
    throw $_.Exception.Message
}