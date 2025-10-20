@echo off
REM Caminho do projeto Flutter
cd /d "C:\Users\Admin\Desktop\FACU\Nova pasta\my_app_viagens"

REM Caminho do adb (edite se necessário)
set ADB_PATH=C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools
set PATH=%PATH%;%ADB_PATH%

REM Nome e ID do emulador
set EMULATOR_NAME=Pixel_8_Pro
set EMULATOR_ID=emulator-5554

REM Verifica se adb está disponível
adb version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: adb nao encontrado! Verifique se o caminho do platform-tools esta correto.
    pause
    exit /b
)

REM Verifica se o emulador ja esta rodando
adb devices | find "%EMULATOR_ID%" >nul
if %errorlevel% neq 0 (
    echo Iniciando o emulador %EMULATOR_NAME%...
    flutter emulators --launch %EMULATOR_NAME%
    echo Aguardando o emulador inicializar (30s)...
    timeout /t 30 /nobreak
) else (
    echo Emulador ja esta rodando.
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
