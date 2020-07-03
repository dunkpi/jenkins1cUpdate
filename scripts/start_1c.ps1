# Скрипт запуска 1С Предприятие и выполнения внешней обработки

# --- Ввод параметров подключения ---
Param (
    [Parameter()][string]$platform1c = '',
    [Parameter()][string]$server1c = '',
    [Parameter()][string]$infobase = '',
    [Parameter()][string]$user = '',
    [Parameter()][string]$passw = ''
)
# --- Рабочая часть скрипта ---
try {
    $connectionString ='ENTERPRISE /S' + $server1c + '\' + $infobase + ' /N' + $user + ' /P' + $passw + ' /Execute "tools\quit1c.epf"'
    Write-Host $connectionString
    & $platform1c $connectionString | Out-Null
} catch {
    throw $_.Exception.Message
}