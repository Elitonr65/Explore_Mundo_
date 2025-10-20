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

REM Verifica se algum emulador ja esta rodando
for /f "tokens=1,2" %%a in ('adb devices ^| findstr emulator') do (
    set EMULATOR_ID=%%a
)

if defined EMULATOR_ID (
    echo Emulador ja esta rodando: %EMULATOR_ID%
) else (
    REM Pega o primeiro emulador disponível
    for /f "tokens=1,2" %%a in ('flutter emulators') do (
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
    REM Espera inicializar
    timeout /t 30 /nobreak
    set EMULATOR_ID=emulator-5554
)

REM Aguarda o dispositivo ficar pronto
:check_device
for /f "tokens=2" %%a in ('adb devices ^| find "%EMULATOR_ID%"') do set STATUS=%%a
if "%STATUS%"=="device" (
    echo Emulador pronto!
) else (
    echo Emulador ainda inicializando, aguardando 5 segundos...
    timeout /t 5 /nobreak >nul
    goto check_device
)

REM Roda o app no emulador
echo Iniciando o app Flutter no emulador...
flutter run -d %EMULATOR_ID%

pause
