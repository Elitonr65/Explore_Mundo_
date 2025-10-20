# Caminho do seu projeto Flutter
$projectPath = "C:\Users\Admin\Desktop\FACU\Nova pasta\my_app_viagens"
Set-Location $projectPath

# Nome e ID do emulador
$emulatorName = "Pixel_8_Pro"
$emulatorId = "emulator-5554"

# Verifica se o emulador já está rodando
$devices = flutter devices
if ($devices -notmatch $emulatorId) {
    Write-Host "Iniciando o emulador $emulatorName..."
    flutter emulators --launch $emulatorName
    Write-Host "Aguardando o emulador iniciar..."
    Start-Sleep -s 15 # aguarda 15 segundos para o emulador inicializar
} else {
    Write-Host "Emulador já está rodando."
}

# Roda o app no emulador
Write-Host "Iniciando o app no emulador..."
flutter run -d $emulatorId
