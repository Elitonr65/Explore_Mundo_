@echo off
REM Caminho do projeto Flutter
cd /d "C:\Users\Admin\Desktop\FACU\Nova pasta\my_app_viagens"

REM Caminho do adb (edite se necessário)
set ADB_PATH=C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools
set PATH=%PATH%;%ADB_PATH%

REM Verifica se adb está disponível
adb version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: adb nao encontrado! Verifique se o caminho do platform-tools esta correto.
    pause
    exit /b
)

REM Lista dispositivos conectados
echo Verificando dispositivos conectados...
set DEVICE_FOUND=false
for /f "skip=1 tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="device" (
        echo Dispositivo encontrado: %%a
        set DEVICE_FOUND=true
        set DEVICE_ID=%%a
    )
)

REM Se nenhum dispositivo conectado, tenta iniciar um emulador
if "%DEVICE_FOUND%"=="false" (
    echo Nenhum dispositivo conectado. Iniciando emulador...
    REM Pega o primeiro emulador disponível
    for /f "skip=2 tokens=1,2" %%a in ('flutter emulators') do (
        set EMULATOR_NAME=%%a
        goto launch_emulator
    )
    :launch_emulator
    if not defined EMULATOR_NAME (
        echo Nenhum emulador configurado. Crie um no Android Studio (AVD Manager).
        pause
        exit /b
    )
    echo Iniciando emulador %EMULATOR_NAME%...
    flutter emulators --launch %EMULATOR_NAME%
    set DEVICE_ID=emulator-5554
    echo Esperando o emulador inicializar (30s)...
    timeout /t 30 /nobreak
)

REM Aguarda o dispositivo ficar pronto
:check_device
for /f "tokens=2" %%a in ('adb devices ^| find "%DEVICE_ID%"') do set STATUS=%%a
if "%STATUS%"=="device" (
    echo Dispositivo pronto: %DEVICE_ID%
) else (
    echo Dispositivo ainda inicializando, aguardando 5 segundos...
    timeout /t 5 /nobreak >nul
    goto check_device
)

REM Roda o app no dispositivo/emulador
echo Iniciando o app Flutter em %DEVICE_ID%...
flutter run -d %DEVICE_ID%

pause
