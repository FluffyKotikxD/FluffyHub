@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ================================
:: БАЗОВАЯ КОНФИГУРАЦИЯ
:: ================================
title FluffyHub Toolbox 2025 by kotikxD
mode con: cols=100 lines=55

:: Инициализация всех переменных (чтобы не было ошибок)
set "ROOT_DIR=%~dp0"
if "%ROOT_DIR%"=="" set "ROOT_DIR=%cd%\"
if not "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR%\"

:: Инициализация всех путей и настроек ДО их использования
set "CONFIG_FILE=%ROOT_DIR%Data\config.cfg"
set "LOG_FILE=%ROOT_DIR%Logs\toolbox_%date:~6,4%%date:~3,2%%date:~0,2%.log"
set "ADB_PATH="
set "SAVED_ADB_PATH="
set "USER_ADB_PATH="  :: ДОБАВЛЕНО: инициализация переменной
set "LANGUAGE=RU"
set "COLOR_NORMAL=07"
set "COLOR_SUCCESS=0A"
set "COLOR_ERROR=0C"
set "COLOR_MENU=1F"
set "COLOR_INFO=3F"
set "COLOR_WARNING=0E"
set "COLOR_HIGHLIGHT=9F"

:: Создаем все папки программы
for %%f in ("Data" "Backups" "Reports" "Temp" "Logs" "APKs" "Scripts" "Cache" "Downloads" "Recovery") do (
    if not exist "%ROOT_DIR%%%f\" mkdir "%ROOT_DIR%%%f\"
)

:: Загружаем конфиг если есть
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%CONFIG_FILE%") do (
        if "%%a"=="COLOR_NORMAL" set "COLOR_NORMAL=%%b"
        if "%%a"=="COLOR_SUCCESS" set "COLOR_SUCCESS=%%b"
        if "%%a"=="COLOR_ERROR" set "COLOR_ERROR=%%b"
        if "%%a"=="COLOR_MENU" set "COLOR_MENU=%%b"
        if "%%a"=="COLOR_INFO" set "COLOR_INFO=%%b"
        if "%%a"=="COLOR_WARNING" set "COLOR_WARNING=%%b"
        if "%%a"=="COLOR_HIGHLIGHT" set "COLOR_HIGHLIGHT=%%b"
        if "%%a"=="SAVED_ADB_PATH" set "SAVED_ADB_PATH=%%b"
        if "%%a"=="LANGUAGE" set "LANGUAGE=%%b"
        if "%%a"=="USER_ADB_PATH" set "USER_ADB_PATH=%%b"  :: ИСПРАВЛЕНО: загрузка пользовательского пути
        if "%%a"=="BACKUP_FOLDER" set "BACKUP_FOLDER=%%b"
    )
)

:: Проверка администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo    [ WARNING ]: Program running without admin rights!
    echo    Some functions may not work:
    echo    • Driver installation
    echo    • ADB download to system folders
    echo    • Working with some system partitions
    echo.
    color 07
    timeout /t 3 >nul
)

:: Логирование старта
echo [%time%] === FluffyHub Toolbox Started === >> "%LOG_FILE%"

:: ================================
:: ЗАСТАВКА И ЗАГРУЗКА
:: ================================
cls
echo.
echo    #################################################
echo    #           FLUFFYHUB TOOLBOX 2025            #
echo    #               by kotikxD                    #
echo    #################################################
echo.

:: Простая анимация загрузки
for /l %%i in (1,1,10) do (
    set "dots="
    for /l %%j in (1,1,%%i) do set "dots=!dots!."
    cls
    echo.
    echo    #################################################
    echo    #           FLUFFYHUB TOOLBOX 2025            #
    echo    #               by kotikxD                    #
    echo    #################################################
    echo.
    if "!LANGUAGE!"=="RU" (
        echo    Загрузка системы!dots!
        echo.
        echo    Прогресс: [%%i0%%]
    ) else (
        echo    Loading system!dots!
        echo.
        echo    Progress: [%%i0%%]
    )
    ping -n 1 127.0.0.1 >nul
)

:: ================================
:: ПРОВЕРКА И ПОИСК ADB
:: ================================
:check_adb
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ПОИСК ADB И FASTBOOT              #
    echo    #################################################
) else (
    echo    #################################################
    echo    #           ADB AND FASTBOOT SEARCH           #
    echo    #################################################
)
echo.

set ADB_FOUND=0
set ADB_PATH=

:: 1. Проверяем сохраненный путь из конфига (сначала USER_ADB_PATH, потом SAVED_ADB_PATH)
if defined USER_ADB_PATH (
    if exist "!USER_ADB_PATH!\adb.exe" (
        set ADB_PATH=!USER_ADB_PATH!
        set ADB_FOUND=1
        if "!LANGUAGE!"=="RU" (
            echo    Найден в пользовательском пути: !ADB_PATH!
        ) else (
            echo    Found in user path: !ADB_PATH!
        )
    )
)

if !ADB_FOUND!==0 (
    if defined SAVED_ADB_PATH (
        if exist "!SAVED_ADB_PATH!\adb.exe" (
            set ADB_PATH=!SAVED_ADB_PATH!
            set ADB_FOUND=1
            if "!LANGUAGE!"=="RU" (
                echo    Найден в сохраненном пути: !ADB_PATH!
            ) else (
                echo    Found in saved path: !ADB_PATH!
            )
        )
    )
)

:: 2. Проверяем стандартные пути
if !ADB_FOUND!==0 (
    for %%p in (
        "C:\platform-tools"
        "%ROOT_DIR%platform-tools"
        "%ROOT_DIR%"
        "%ProgramFiles%\Android\Android SDK\platform-tools"
        "%LocalAppData%\Android\Sdk\platform-tools"
        "C:\adb"
        "D:\platform-tools"
        "D:\adb"
    ) do (
        if exist "%%~p\adb.exe" (
            set ADB_PATH=%%~p
            set ADB_FOUND=1
            if "!LANGUAGE!"=="RU" (
                echo    Найден в: !ADB_PATH!
            ) else (
                echo    Found in: !ADB_PATH!
            )
            goto :adb_found_check
        )
    )
)

:adb_found_check
if !ADB_FOUND!==1 goto adb_found

:: ADB не найден
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    ADB не найден!
    echo.
    echo    [1] Указать путь вручную
    echo    [2] Скачать ADB автоматически
    echo    [3] Продолжить без ADB
    echo    [4] Настройки программы
    echo    [5] Выход
    echo.
    set /p "adb_choice=   Ваш выбор [1-5]: "
) else (
    echo    ADB not found!
    echo.
    echo    [1] Enter path manually
    echo    [2] Download ADB automatically
    echo    [3] Continue without ADB
    echo    [4] Program settings
    echo    [5] Exit
    echo.
    set /p "adb_choice=   Your choice [1-5]: "
)

if "!adb_choice!"=="1" goto manual_adb_path
if "!adb_choice!"=="2" goto download_adb
if "!adb_choice!"=="3" goto adb_not_found_continue
if "!adb_choice!"=="4" goto program_settings
if "!adb_choice!"=="5" goto exit_prog
goto check_adb

:manual_adb_path
cls
echo.
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ВЫБОР ПУТИ К ADB                  #
    echo    #################################################
    echo.
    echo    Примеры:
    echo    • C:\platform-tools
    echo    • D:\Android\SDK\platform-tools
    echo    • %cd%\platform-tools
    echo.
    set /p "ADB_PATH=   Введите путь к папке с adb.exe: "
) else (
    echo    #################################################
    echo    #           CHOOSE ADB PATH                    #
    echo    #################################################
    echo.
    echo    Examples:
    echo    • C:\platform-tools
    echo    • D:\Android\SDK\platform-tools
    echo    • %cd%\platform-tools
    echo.
    set /p "ADB_PATH=   Enter path to folder with adb.exe: "
)

if "!ADB_PATH!"=="" goto check_adb

:: Запоминаем пользовательский путь - ИСПРАВЛЕНО: сохраняем в USER_ADB_PATH
set "USER_ADB_PATH=!ADB_PATH!"
call :save_config "USER_ADB_PATH" "!ADB_PATH!"

if not exist "!ADB_PATH!\adb.exe" (
    color %COLOR_ERROR%
    echo.
    if "!LANGUAGE!"=="RU" (
        echo    [ ОШИБКА ]: adb.exe не найден по указанному пути!
    ) else (
        echo    [ ERROR ]: adb.exe not found in specified path!
    )
    echo.
    color %COLOR_NORMAL%
    pause
    goto check_adb
)
goto adb_found

:download_adb
cls
echo.
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           СКАЧИВАНИЕ ADB                    #
    echo    #################################################
    echo.
    echo    Выберите тип загрузки:
    echo    [1] Скачать platform-tools
    echo    [2] Скачать минимальный ADB
    echo    [3] Назад
    echo.
    set /p "dl_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           DOWNLOAD ADB                       #
    echo    #################################################
    echo.
    echo    Select download type:
    echo    [1] Download platform-tools
    echo    [2] Download minimal ADB
    echo    [3] Back
    echo.
    set /p "dl_choice=   Select: "
)

if "!dl_choice!"=="3" goto check_adb
if "!dl_choice!"=="1" (
    set "adbfile=platform-tools.zip"
    set "adbfolder=platform-tools"
)
if "!dl_choice!"=="2" (
    set "adbfile=minimal_adb.zip"
    set "adbfolder=minimal_adb"
)

echo.
if "!LANGUAGE!"=="RU" (
    echo    Скачивание...
    echo    Пожалуйста, подождите...
) else (
    echo    Downloading...
    echo    Please wait...
)

powershell -Command "& {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    if ('!dl_choice!' -eq '1') {
        Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile '%ROOT_DIR%Temp\!adbfile!' -UseBasicParsing
    } else {
        Invoke-WebRequest -Uri 'https://github.com/joshuaboniface/adb-winapi/releases/download/v1.0.40/adb-winapi.zip' -OutFile '%ROOT_DIR%Temp\!adbfile!' -UseBasicParsing
    }
}" >nul 2>&1

if not exist "%ROOT_DIR%Temp\!adbfile!" (
    color %COLOR_ERROR%
    echo.
    if "!LANGUAGE!"=="RU" (
        echo    [ ОШИБКА ]: Не удалось скачать ADB!
        echo    Проверьте подключение к интернету.
    ) else (
        echo    [ ERROR ]: Failed to download ADB!
        echo    Check your internet connection.
    )
    echo.
    color %COLOR_NORMAL%
    pause
    goto check_adb
)

if "!LANGUAGE!"=="RU" (
    echo    Распаковка...
) else (
    echo    Extracting...
)
powershell -Command "Expand-Archive -Path '%ROOT_DIR%Temp\!adbfile!' -DestinationPath '%ROOT_DIR%' -Force" >nul 2>&1
del "%ROOT_DIR%Temp\!adbfile!" 2>nul

set "ADB_PATH=%ROOT_DIR%!adbfolder!"
if not exist "!ADB_PATH!\adb.exe" (
    color %COLOR_ERROR%
    echo.
    if "!LANGUAGE!"=="RU" (
        echo    [ ОШИБКА ]: Не удалось распаковать ADB!
    ) else (
        echo    [ ERROR ]: Failed to extract ADB!
    )
    echo.
    color %COLOR_NORMAL%
    pause
    goto check_adb
)

color %COLOR_SUCCESS%
echo.
if "!LANGUAGE!"=="RU" (
    echo    [ УСПЕХ ]: ADB успешно скачан и установлен!
    echo    Путь: !ADB_PATH!
) else (
    echo    [ SUCCESS ]: ADB successfully downloaded and installed!
    echo    Path: !ADB_PATH!
)
echo.
color %COLOR_NORMAL%
timeout /t 2 >nul
goto adb_found

:adb_not_found_continue
color %COLOR_WARNING%
echo.
if "!LANGUAGE!"=="RU" (
    echo    [ ВНИМАНИЕ ]: ADB не найден!
    echo    Многие функции будут недоступны.
    echo    Рекомендуется установить ADB.
) else (
    echo    [ WARNING ]: ADB not found!
    echo    Many features will be unavailable.
    echo    Recommended to install ADB.
)
echo.
color %COLOR_NORMAL%
set ADB_PATH=NOT_FOUND
timeout /t 2 >nul
goto main_menu

:adb_found
:: Сохраняем путь в конфиг
set "SAVED_ADB_PATH=!ADB_PATH!"
call :save_config "SAVED_ADB_PATH" "!ADB_PATH!"

:: Добавляем ADB в PATH
set "PATH=!ADB_PATH!;%PATH%"

cls
color %COLOR_SUCCESS%
echo.
if "!LANGUAGE!"=="RU" (
    echo    [ УСПЕХ ]: ADB найден и готов к работе!
    echo    Путь: !ADB_PATH!
) else (
    echo    [ SUCCESS ]: ADB found and ready to work!
    echo    Path: !ADB_PATH!
)
echo.
color %COLOR_NORMAL%

if "!LANGUAGE!"=="RU" (
    echo    Проверка подключения устройства...
) else (
    echo    Checking device connection...
)
adb devices > "%ROOT_DIR%Temp\adb_check.tmp" 2>&1
findstr /r /c:"device$" "%ROOT_DIR%Temp\adb_check.tmp" >nul
if errorlevel 1 (
    color %COLOR_WARNING%
    if "!LANGUAGE!"=="RU" (
        echo    Устройство не подключено или не авторизовано.
        echo    Включите отладку по USB на телефоне.
    ) else (
        echo    Device not connected or not authorized.
        echo    Enable USB debugging on your phone.
    )
    echo.
    color %COLOR_NORMAL%
) else (
    color %COLOR_SUCCESS%
    if "!LANGUAGE!"=="RU" (
        echo    Устройство подключено!
    ) else (
        echo    Device connected!
    )
    echo.
    color %COLOR_NORMAL%
)
del "%ROOT_DIR%Temp\adb_check.tmp" 2>nul
timeout /t 2 >nul

:: ================================
:: ГЛАВНОЕ МЕНЮ (19 ПУНКТОВ)
:: ================================
:main_menu
cls
color %COLOR_MENU%
echo    #################################################
echo    #           FLUFFYHUB TOOLBOX 2025            #
echo    #               by kotikxD                    #
echo    #-----------------------------------------------#
if "!LANGUAGE!"=="RU" (
    echo    #   ADB: !ADB_PATH!                          #
    echo    #   Язык: !LANGUAGE!                         #
) else (
    echo    #   ADB: !ADB_PATH!                          #
    echo    #   Language: !LANGUAGE!                     #
)
echo    #-----------------------------------------------#
if "!LANGUAGE!"=="RU" (
    echo    #   [1]  Проверить подключение             #
    echo    #   [2]  Перезагрузить в Fastboot           #
    echo    #   [3]  Проверить Fastboot                 #
    echo    #   [4]  Зайти в загрузчик                  #
    echo    #   [5]  Разблокировка загрузчика           #
    echo    #   [6]  Установить приложение              #
    echo    #   [7]  Сделать бэкап                      #
    echo    #   [8]  Сохранить данные                   #
    echo    #   [9]  Команды Fastboot                   #
    echo    #   [10] Командная строка ADB               #
    echo    #   [11] Управление файлами                 #
    echo    #   [12] Сброс и форматирование             #
    echo    #   [13] Восстановление системы             #
    echo    #   [14] Информация о телефоне              #
    echo    #   [15] Очистка памяти                     #
    echo    #   [16] Настройки программы                #
    echo    #   [17] Утилиты и инструменты              #
    echo    #   [18] О программе                        #
    echo    #   [19] Выход                              #
) else (
    echo    #   [1]  Check connection                  #
    echo    #   [2]  Reboot to Fastboot                #
    echo    #   [3]  Check Fastboot                    #
    echo    #   [4]  Enter bootloader                  #
    echo    #   [5]  Unlock bootloader                 #
    echo    #   [6]  Install application               #
    echo    #   [7]  Create backup                     #
    echo    #   [8]  Save data                         #
    echo    #   [9]  Fastboot commands                 #
    echo    #   [10] ADB command line                  #
    echo    #   [11] File manager                      #
    echo    #   [12] Wipe and format                   #
    echo    #   [13] System recovery                   #
    echo    #   [14] Phone information                 #
    echo    #   [15] Memory cleanup                    #
    echo    #   [16] Program settings                  #
    echo    #   [17] Utilities and tools               #
    echo    #   [18] About                             #
    echo    #   [19] Exit                              #
)
echo    #################################################
echo.
if "!LANGUAGE!"=="RU" (
    set "choice="
    set /p "choice=   Ваш выбор [1-19]: "
) else (
    set "choice="
    set /p "choice=   Your choice [1-19]: "
)

if "!choice!"=="1" goto check_device
if "!choice!"=="2" goto reboot_fastboot
if "!choice!"=="3" goto check_fastboot
if "!choice!"=="4" goto bootloader_menu
if "!choice!"=="5" goto unlock_bootloader
if "!choice!"=="6" goto install_app_menu
if "!choice!"=="7" goto backup_menu
if "!choice!"=="8" goto backup_data
if "!choice!"=="9" goto fastboot_commands
if "!choice!"=="10" goto adb_shell
if "!choice!"=="11" goto file_manager_menu
if "!choice!"=="12" goto wipe_menu
if "!choice!"=="13" goto recovery_menu
if "!choice!"=="14" goto phone_info_menu
if "!choice!"=="15" goto cleanup_menu
if "!choice!"=="16" goto program_settings
if "!choice!"=="17" goto utilities_menu
if "!choice!"=="18" goto about_menu
if "!choice!"=="19" goto exit_prog
goto main_menu

:: ================================
:: 1. ПРОВЕРИТЬ ПОДКЛЮЧЕНИЕ
:: ================================
:check_device
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ПРОВЕРКА ПОДКЛЮЧЕНИЯ             #
    echo    #################################################
) else (
    echo    #################################################
    echo    #           CHECK CONNECTION                  #
    echo    #################################################
)
echo.
if "!LANGUAGE!"=="RU" (
    echo    Проверяю подключение...
) else (
    echo    Checking connection...
)
echo.
adb devices > "%ROOT_DIR%Temp\devices.tmp" 2>&1
type "%ROOT_DIR%Temp\devices.tmp"
echo.
findstr /r /c:"device$" "%ROOT_DIR%Temp\devices.tmp" >nul

if errorlevel 1 (
    color %COLOR_ERROR%
    if "!LANGUAGE!"=="RU" (
        echo    [ ОШИБКА ]: Устройство не подключено!
        echo    Включите отладку по USB на телефоне.
    ) else (
        echo    [ ERROR ]: Device not connected!
        echo    Enable USB debugging on your phone.
    )
    echo.
    color %COLOR_NORMAL%
) else (
    color %COLOR_SUCCESS%
    if "!LANGUAGE!"=="RU" (
        echo    [ УСПЕХ ]: Устройство подключено!
    ) else (
        echo    [ SUCCESS ]: Device connected!
    )
    echo.
    color %COLOR_NORMAL%
    if "!LANGUAGE!"=="RU" (
        echo    Информация об устройстве:
        echo    -------------------------
        echo    Модель: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.product.model 2^>nul') do echo    %%i
        echo    Производитель: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.product.manufacturer 2^>nul') do echo    %%i
        echo    Android: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.release 2^>nul') do echo    %%i
        echo    Серийный номер: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.serialno 2^>nul') do echo    %%i
    ) else (
        echo    Device information:
        echo    -------------------------
        echo    Model: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.product.model 2^>nul') do echo    %%i
        echo    Manufacturer: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.product.manufacturer 2^>nul') do echo    %%i
        echo    Android: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.release 2^>nul') do echo    %%i
        echo    Serial number: 
        for /f "tokens=*" %%i in ('adb shell getprop ro.serialno 2^>nul') do echo    %%i
    )
)
del "%ROOT_DIR%Temp\devices.tmp" 2>nul
echo.
pause
goto main_menu

:: ================================
:: 2. ПЕРЕЗАГРУЗИТЬ В FASTBOOT
:: ================================
:reboot_fastboot
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ПЕРЕЗАГРУЗКА В FASTBOOT          #
    echo    #################################################
) else (
    echo    #################################################
    echo    #           REBOOT TO FASTBOOT               #
    echo    #################################################
)
echo.
adb devices >nul 2>&1
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Устройство не подключено!
        echo    Подключите телефон с включенной отладкой USB
    ) else (
        echo    Device not connected!
        echo    Connect phone with USB debugging enabled
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Отправляю команду перезагрузки в Fastboot...
    ) else (
        echo    Sending reboot to Fastboot command...
    )
    adb reboot bootloader >nul 2>&1
    if errorlevel 1 (
        color %COLOR_ERROR%
        echo.
        if "!LANGUAGE!"=="RU" (
            echo    [ ОШИБКА ]: Не удалось отправить команду!
            echo    Проверьте права отладки по USB.
        ) else (
            echo    [ ERROR ]: Failed to send command!
            echo    Check USB debugging permissions.
        )
        echo.
        color %COLOR_NORMAL%
    ) else (
        color %COLOR_SUCCESS%
        echo.
        if "!LANGUAGE!"=="RU" (
            echo    [ УСПЕХ ]: Команда отправлена!
            echo    Телефон перезагружается в Fastboot...
        ) else (
            echo    [ SUCCESS ]: Command sent!
            echo    Phone rebooting to Fastboot...
        )
        echo.
        color %COLOR_NORMAL%
    )
)
echo.
pause
goto main_menu

:: ================================
:: 3. ПРОВЕРИТЬ FASTBOOT
:: ================================
:check_fastboot
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ПРОВЕРКА FASTBOOT                 #
    echo    #################################################
) else (
    echo    #################################################
    echo    #           CHECK FASTBOOT                    #
    echo    #################################################
)
echo.
if "!LANGUAGE!"=="RU" (
    echo    Проверяю подключение в режиме Fastboot...
) else (
    echo    Checking Fastboot connection...
)
echo.
fastboot devices > "%ROOT_DIR%Temp\fastboot.tmp" 2>&1
type "%ROOT_DIR%Temp\fastboot.tmp"
echo.
findstr "." "%ROOT_DIR%Temp\fastboot.tmp" >nul

if errorlevel 1 (
    color %COLOR_ERROR%
    if "!LANGUAGE!"=="RU" (
        echo    [ ОШИБКА ]: Fastboot не отвечает!
        echo    Убедитесь что:
        echo    • Телефон в режиме Fastboot
        echo    • Установлены драйверы Fastboot
        echo    • Надежный USB кабель
    ) else (
        echo    [ ERROR ]: Fastboot not responding!
        echo    Ensure that:
        echo    • Phone is in Fastboot mode
        echo    • Fastboot drivers installed
        echo    • Reliable USB cable
    )
    echo.
    color %COLOR_NORMAL%
) else (
    color %COLOR_SUCCESS%
    if "!LANGUAGE!"=="RU" (
        echo    [ УСПЕХ ]: Fastboot работает!
    ) else (
        echo    [ SUCCESS ]: Fastboot working!
    )
    echo.
    color %COLOR_NORMAL%
)
del "%ROOT_DIR%Temp\fastboot.tmp" 2>nul
echo.
pause
goto main_menu

:: ================================
:: 4. ЗАЙТИ В ЗАГРУЗЧИК
:: ================================
:bootloader_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           РЕЖИМЫ ЗАГРУЗКИ                  #
    echo    #################################################
) else (
    echo    #################################################
    echo    #           BOOT MODES                        #
    echo    #################################################
)
echo.
adb devices >nul 2>&1
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Устройство не подключено в ADB режиме!
    ) else (
        echo    Device not connected in ADB mode!
    )
    pause
    goto main_menu
)

if "!LANGUAGE!"=="RU" (
    echo    Устройство подключено.
    echo.
    echo    Выберите режим загрузки:
    echo    [1] Загрузиться в Recovery
    echo    [2] Загрузиться в Download
    echo    [3] Загрузиться в EDL
    echo    [4] Загрузиться в Safe Mode
    echo    [5] Назад
    echo.
    set /p "boot_choice=   Выберите: "
) else (
    echo    Device connected.
    echo.
    echo    Select boot mode:
    echo    [1] Boot to Recovery
    echo    [2] Boot to Download
    echo    [3] Boot to EDL
    echo    [4] Boot to Safe Mode
    echo    [5] Back
    echo.
    set /p "boot_choice=   Select: "
)

if "!boot_choice!"=="1" (
    adb reboot recovery >nul 2>&1
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка в Recovery...
    ) else (
        echo    Rebooting to Recovery...
    )
)
if "!boot_choice!"=="2" (
    adb reboot download >nul 2>&1
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка в Download...
    ) else (
        echo    Rebooting to Download...
    )
)
if "!boot_choice!"=="3" (
    adb reboot edl >nul 2>&1
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка в EDL...
    ) else (
        echo    Rebooting to EDL...
    )
)
if "!boot_choice!"=="4" (
    adb shell "am start -a android.intent.action.REBOOT" >nul 2>&1
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка в Safe Mode...
    ) else (
        echo    Rebooting to Safe Mode...
    )
)
if "!boot_choice!"=="5" goto main_menu

timeout /t 2 >nul
goto bootloader_menu

:: ================================
:: 5. РАЗБЛОКИРОВКА ЗАГРУЗЧИКА
:: ================================
:unlock_bootloader
cls
color %COLOR_WARNING%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           РАЗБЛОКИРОВКА ЗАГРУЗЧИКА         #
    echo    #################################################
    echo.
    echo    ВНИМАНИЕ: Это удалит ВСЕ данные с телефона!
    echo    Выполняйте только если понимаете что делаете!
) else (
    echo    #################################################
    echo    #           UNLOCK BOOTLOADER                 #
    echo    #################################################
    echo.
    echo    WARNING: This will delete ALL data from phone!
    echo    Perform only if you know what you're doing!
)
echo.
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    Проверяю подключение в Fastboot...
) else (
    echo    Checking Fastboot connection...
)
fastboot devices >nul 2>&1
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Устройство не в режиме Fastboot!
        echo    Перезагрузите телефон в Fastboot.
    ) else (
        echo    Device not in Fastboot mode!
        echo    Reboot phone to Fastboot.
    )
    pause
    goto main_menu
)

if "!LANGUAGE!"=="RU" (
    echo    Устройство в Fastboot.
    echo.
    set /p "confirm=   Введите 'РАЗБЛОКИРОВАТЬ' для подтверждения: "
) else (
    echo    Device in Fastboot.
    echo.
    set /p "confirm=   Enter 'UNLOCK' to confirm: "
)

if "!LANGUAGE!"=="RU" (
    if /i not "!confirm!"=="РАЗБЛОКИРОВАТЬ" goto main_menu
) else (
    if /i not "!confirm!"=="UNLOCK" goto main_menu
)

echo.
if "!LANGUAGE!"=="RU" (
    echo    Выполняю разблокировку...
) else (
    echo    Executing unlock...
)
fastboot flashing unlock >nul 2>&1
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Пробую альтернативную команду...
    ) else (
        echo    Trying alternative command...
    )
    fastboot oem unlock >nul 2>&1
)

if errorlevel 1 (
    color %COLOR_ERROR%
    echo.
    if "!LANGUAGE!"=="RU" (
        echo    [ ОШИБКА ]: Не удалось разблокировать!
        echo    Возможно, разблокировка отключена производителем.
    ) else (
        echo    [ ERROR ]: Failed to unlock!
        echo    Possibly unlock disabled by manufacturer.
    )
    echo.
    color %COLOR_NORMAL%
) else (
    color %COLOR_SUCCESS%
    echo.
    if "!LANGUAGE!"=="RU" (
        echo    [ УСПЕХ ]: Команда отправлена!
        echo    Смотрите инструкции на экране телефона.
    ) else (
        echo    [ SUCCESS ]: Command sent!
        echo    Follow instructions on phone screen.
    )
    echo.
    color %COLOR_NORMAL%
)
echo.
pause
goto main_menu

:: ================================
:: 6. УСТАНОВИТЬ ПРИЛОЖЕНИЕ
:: ================================
:install_app_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           УСТАНОВКА ПРИЛОЖЕНИЯ            #
    echo    #################################################
    echo.
    echo    [1] Установить APK файл
    echo    [2] Установить из папки APKs
    echo    [3] Массовая установка
    echo    [4] Удалить приложение
    echo    [5] Назад
    echo.
    set /p "install_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           INSTALL APPLICATION              #
    echo    #################################################
    echo.
    echo    [1] Install APK file
    echo    [2] Install from APKs folder
    echo    [3] Mass installation
    echo    [4] Uninstall application
    echo    [5] Back
    echo.
    set /p "install_choice=   Select: "
)

if "!install_choice!"=="1" goto install_single_apk
if "!install_choice!"=="2" goto install_from_folder
if "!install_choice!"=="3" goto mass_install
if "!install_choice!"=="4" goto uninstall_app
if "!install_choice!"=="5" goto main_menu
goto install_app_menu

:install_single_apk
cls
echo.
if "!LANGUAGE!"=="RU" (
    echo    Введите путь к APK файлу:
    echo    Или перетащите файл в это окно
    echo.
    set /p "apk_path=   Путь: "
) else (
    echo    Enter path to APK file:
    echo    Or drag and drop file into this window
    echo.
    set /p "apk_path=   Path: "
)
if "!apk_path!"=="" goto install_app_menu

:: Убираем кавычки если они есть
set "apk_path=!apk_path:"=!"
if not exist "!apk_path!" (
    if "!LANGUAGE!"=="RU" (
        echo    Файл не найден!
    ) else (
        echo    File not found!
    )
    pause
    goto install_single_apk
)

if "!LANGUAGE!"=="RU" (
    echo    Установка: !apk_path!
) else (
    echo    Installing: !apk_path!
)
adb install -r "!apk_path!" 2>nul
if errorlevel 1 (
    color %COLOR_ERROR%
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка установки!
        echo    Попробуйте: adb install -g "!apk_path!"
    ) else (
        echo    Installation error!
        echo    Try: adb install -g "!apk_path!"
    )
    echo.
    color %COLOR_NORMAL%
) else (
    color %COLOR_SUCCESS%
    if "!LANGUAGE!"=="RU" (
        echo    Установлено успешно!
    ) else (
        echo    Successfully installed!
    )
    echo.
    color %COLOR_NORMAL%
)
pause
goto install_app_menu

:install_from_folder
echo.
if "!LANGUAGE!"=="RU" (
    echo    Файлы в папке APKs:
) else (
    echo    Files in APKs folder:
)
dir "%ROOT_DIR%APKs\*.apk" /b 2>nul || (
    if "!LANGUAGE!"=="RU" (
        echo    Папка пуста
    ) else (
        echo    Folder empty
    )
)
echo.
if "!LANGUAGE!"=="RU" (
    set /p "apk_name=   Имя файла: "
) else (
    set /p "apk_name=   File name: "
)
if "!apk_name!"=="" goto install_app_menu

if not exist "%ROOT_DIR%APKs\!apk_name!" (
    if "!LANGUAGE!"=="RU" (
        echo    Файл не найден!
    ) else (
        echo    File not found!
    )
    pause
    goto install_from_folder
)

adb install -r "%ROOT_DIR%APKs\!apk_name!" 2>nul
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка установки!
    ) else (
        echo    Installation error!
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Успешно установлено!
    ) else (
        echo    Successfully installed!
    )
)
pause
goto install_app_menu

:mass_install
echo.
if "!LANGUAGE!"=="RU" (
    echo    Массовая установка всех APK из папки...
) else (
    echo    Mass installation of all APKs from folder...
)
for %%f in ("%ROOT_DIR%APKs\*.apk") do (
    if "!LANGUAGE!"=="RU" (
        echo    Установка: %%~nxf
    ) else (
        echo    Installing: %%~nxf
    )
    adb install -r "%%f" >nul 2>&1 && (
        if "!LANGUAGE!"=="RU" (
            echo    [OK]
        ) else (
            echo    [OK]
        )
    ) || (
        if "!LANGUAGE!"=="RU" (
            echo    [FAIL]
        ) else (
            echo    [FAIL]
        )
    )
)
pause
goto install_app_menu

:uninstall_app
echo.
if "!LANGUAGE!"=="RU" (
    set /p "package_name=   Имя пакета для удаления: "
) else (
    set /p "package_name=   Package name to uninstall: "
)
if "!package_name!"=="" goto install_app_menu

adb uninstall !package_name! 2>nul
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка удаления!
    ) else (
        echo    Uninstall error!
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Приложение удалено!
    ) else (
        echo    Application uninstalled!
    )
)
pause
goto install_app_menu

:: ================================
:: 7. СДЕЛАТЬ БЭКАП
:: ================================
:backup_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           СОЗДАНИЕ БЭКАПА                  #
    echo    #################################################
    echo.
    echo    [1] Бэкап приложений (APK + данные)
    echo    [2] Бэкап системной информации
    echo    [3] Бэкап раздела через TWRP
    echo    [4] Полный бэкап (требуется root)
    echo    [5] Назад
    echo.
    set /p "backup_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           CREATE BACKUP                    #
    echo    #################################################
    echo.
    echo    [1] App backup (APK + data)
    echo    [2] System info backup
    echo    [3] Partition backup via TWRP
    echo    [4] Full backup (requires root)
    echo    [5] Back
    echo.
    set /p "backup_choice=   Select: "
)

if "!backup_choice!"=="1" goto backup_apps_data
if "!backup_choice!"=="2" goto backup_system_info
if "!backup_choice!"=="3" goto backup_twrp
if "!backup_choice!"=="4" goto backup_full
if "!backup_choice!"=="5" goto main_menu
goto backup_menu

:backup_apps_data
echo.
if "!LANGUAGE!"=="RU" (
    echo    Создание бэкапа приложений...
) else (
    echo    Creating app backup...
)
set "backup_dir=%ROOT_DIR%Backups\Apps_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%"
mkdir "!backup_dir!" 2>nul

if "!LANGUAGE!"=="RU" (
    echo    Сохраняю список приложений...
) else (
    echo    Saving app list...
)
adb shell "pm list packages -3" > "!backup_dir!\user_apps.txt" 2>nul
adb shell "pm list packages" > "!backup_dir!\all_apps.txt" 2>nul

if "!LANGUAGE!"=="RU" (
    echo    Бэкап завершен!
    echo    Папка: !backup_dir!
) else (
    echo    Backup completed!
    echo    Folder: !backup_dir!
)
pause
goto backup_menu

:backup_system_info
echo.
set "info_file=%ROOT_DIR%Backups\SystemInfo_%date:~6,4%%date:~3,2%%date:~0,2%.txt"
(
if "!LANGUAGE!"=="RU" (
    echo === СИСТЕМНАЯ ИНФОРМАЦИЯ ===
) else (
    echo === SYSTEM INFORMATION ===
)
echo Дата: %date% %time%
echo.
adb shell getprop
) > "!info_file!" 2>nul
if "!LANGUAGE!"=="RU" (
    echo    Информация сохранена: !info_file!
) else (
    echo    Information saved: !info_file!
)
pause
goto backup_menu

:backup_twrp
echo.
if "!LANGUAGE!"=="RU" (
    echo    Для бэкапа через TWRP:
    echo    1. Загрузитесь в TWRP Recovery
    echo    2. Выберите Backup
    echo    3. Выберите разделы для бэкапа
    echo    4. Сохраните на SD карту
    echo    5. Скопируйте файлы на компьютер
) else (
    echo    For backup via TWRP:
    echo    1. Boot into TWRP Recovery
    echo    2. Select Backup
    echo    3. Select partitions to backup
    echo    4. Save to SD card
    echo    5. Copy files to computer
)
pause
goto backup_menu

:backup_full
echo.
if "!LANGUAGE!"=="RU" (
    echo    Полный бэкап требует:
    echo    • Установленный TWRP
    echo    • Root права
    echo    • Достаточно места на SD карте
    echo.
    echo    Используйте TWRP для создания полного бэкапа.
) else (
    echo    Full backup requires:
    echo    • Installed TWRP
    echo    • Root access
    echo    • Enough space on SD card
    echo.
    echo    Use TWRP to create full backup.
)
pause
goto backup_menu

:: ================================
:: 8. СОХРАНИТЬ ДАННЫЕ
:: ================================
:backup_data
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           СОХРАНЕНИЕ ДАННЫХ                #
    echo    #################################################
    echo.
    echo    Введите путь на устройстве для копирования:
    echo    Примеры:
    echo    • /sdcard/DCIM
    echo    • /sdcard/Download
    echo    • /sdcard/Pictures
    echo.
    set /p "device_path=   Путь на устройстве: "
) else (
    echo    #################################################
    echo    #           SAVE DATA                         #
    echo    #################################################
    echo.
    echo    Enter path on device to copy:
    echo    Examples:
    echo    • /sdcard/DCIM
    echo    • /sdcard/Download
    echo    • /sdcard/Pictures
    echo.
    set /p "device_path=   Path on device: "
)
if "!device_path!"=="" goto main_menu

set "local_path=%ROOT_DIR%Backups\Data_%date:~6,4%%date:~3,2%%date:~0,2%"
mkdir "!local_path!" 2>nul

if "!LANGUAGE!"=="RU" (
    echo    Копирование !device_path! ...
) else (
    echo    Copying !device_path! ...
)
adb pull "!device_path!" "!local_path!\" 2>nul
if errorlevel 1 (
    color %COLOR_ERROR%
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка копирования!
    ) else (
        echo    Copy error!
    )
    echo.
    color %COLOR_NORMAL%
) else (
    color %COLOR_SUCCESS%
    if "!LANGUAGE!"=="RU" (
        echo    Данные сохранены в: !local_path!
    ) else (
        echo    Data saved in: !local_path!
    )
    echo.
    color %COLOR_NORMAL%
)
pause
goto main_menu

:: ================================
:: 9. КОМАНДЫ FASTBOOT
:: ================================
:fastboot_commands
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           КОМАНДЫ FASTBOOT                 #
    echo    #################################################
) else (
    echo    #################################################
    echo    #           FASTBOOT COMMANDS                 #
    echo    #################################################
)
echo.
fastboot devices >nul 2>&1
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Устройство не в режиме Fastboot!
    ) else (
        echo    Device not in Fastboot mode!
    )
    pause
    goto main_menu
)

if "!LANGUAGE!"=="RU" (
    echo    Устройство в Fastboot. Выберите команду:
    echo    [1] Перезагрузить в систему
    echo    [2] Перезагрузить в bootloader
    echo    [3] Заблокировать загрузчик
    echo    [4] Стереть cache
    echo    [5] Стереть userdata
    echo    [6] Получить информацию
    echo    [7] Назад
    echo.
    set /p "fb_cmd=   Выберите: "
) else (
    echo    Device in Fastboot. Select command:
    echo    [1] Reboot to system
    echo    [2] Reboot to bootloader
    echo    [3] Lock bootloader
    echo    [4] Erase cache
    echo    [5] Erase userdata
    echo    [6] Get information
    echo    [7] Back
    echo.
    set /p "fb_cmd=   Select: "
)

if "!fb_cmd!"=="1" (
    fastboot reboot
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка...
    ) else (
        echo    Rebooting...
    )
)
if "!fb_cmd!"=="2" (
    fastboot reboot-bootloader
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка в bootloader...
    ) else (
        echo    Rebooting to bootloader...
    )
)
if "!fb_cmd!"=="3" (
    if "!LANGUAGE!"=="RU" (
        echo    ВНИМАНИЕ: Заблокирует загрузчик!
    ) else (
        echo    WARNING: Will lock bootloader!
    )
    fastboot flashing lock
    if "!LANGUAGE!"=="RU" (
        echo    Загрузчик заблокирован...
    ) else (
        echo    Bootloader locked...
    )
)
if "!fb_cmd!"=="4" (
    fastboot erase cache
    if "!LANGUAGE!"=="RU" (
        echo    Cache стерт...
    ) else (
        echo    Cache erased...
    )
)
if "!fb_cmd!"=="5" (
    if "!LANGUAGE!"=="RU" (
        echo    ВНИМАНИЕ: Удалит все данные!
        set /p "confirm=   Продолжить? (y/N): "
    ) else (
        echo    WARNING: Will delete all data!
        set /p "confirm=   Continue? (y/N): "
    )
    if /i "!confirm!"=="y" (
        fastboot erase userdata
        if "!LANGUAGE!"=="RU" (
            echo    Userdata стерт...
        ) else (
            echo    Userdata erased...
        )
    )
)
if "!fb_cmd!"=="6" (
    fastboot getvar all
    echo.
    pause
)
if "!fb_cmd!"=="7" goto main_menu

timeout /t 2 >nul
goto fastboot_commands

:: ================================
:: 10. КОМАНДНАЯ СТРОКА ADB
:: ================================
:adb_shell
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           КОМАНДНАЯ СТРОКА ADB             #
    echo    #################################################
    echo.
    echo    Введите команды ADB. Для выхода введите 'exit'
    echo.
) else (
    echo    #################################################
    echo    #           ADB COMMAND LINE                  #
    echo    #################################################
    echo.
    echo    Enter ADB commands. Type 'exit' to quit
    echo.
)
adb shell
goto main_menu

:: ================================
:: 11. УПРАВЛЕНИЕ ФАЙЛАМИ
:: ================================
:file_manager_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           УПРАВЛЕНИЕ ФАЙЛАМИ              #
    echo    #################################################
    echo.
    echo    [1] Просмотр файлов на устройстве
    echo    [2] Копировать файл на устройство
    echo    [3] Копировать файл с устройства
    echo    [4] Удалить файл на устройстве
    echo    [5] Создать папку на устройстве
    echo    [6] Назад
    echo.
    set /p "fm_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           FILE MANAGER                      #
    echo    #################################################
    echo.
    echo    [1] Browse device files
    echo    [2] Copy file to device
    echo    [3] Copy file from device
    echo    [4] Delete file on device
    echo    [5] Create folder on device
    echo    [6] Back
    echo.
    set /p "fm_choice=   Select: "
)

if "!fm_choice!"=="1" goto browse_files
if "!fm_choice!"=="2" goto push_to_device
if "!fm_choice!"=="3" goto pull_from_device
if "!fm_choice!"=="4" goto delete_file
if "!fm_choice!"=="5" goto create_folder
if "!fm_choice!"=="6" goto main_menu
goto file_manager_menu

:browse_files
echo.
if "!LANGUAGE!"=="RU" (
    set /p "device_path=   Путь на устройстве [/sdcard]: "
) else (
    set /p "device_path=   Path on device [/sdcard]: "
)
if "!device_path!"=="" set "device_path=/sdcard"
adb shell "ls -la !device_path!" 2>nul | more
pause
goto file_manager_menu

:push_to_device
echo.
if "!LANGUAGE!"=="RU" (
    set /p "local_file=   Локальный файл: "
) else (
    set /p "local_file=   Local file: "
)
if not exist "!local_file!" (
    if "!LANGUAGE!"=="RU" (
        echo    Файл не найден!
    ) else (
        echo    File not found!
    )
    pause
    goto file_manager_menu
)
if "!LANGUAGE!"=="RU" (
    set /p "remote_path=   Путь на устройстве: "
) else (
    set /p "remote_path=   Path on device: "
)
adb push "!local_file!" "!remote_path!" 2>nul && (
    if "!LANGUAGE!"=="RU" (
        echo    Файл скопирован!
    ) else (
        echo    File copied!
    )
) || (
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка копирования!
    ) else (
        echo    Copy error!
    )
)
pause
goto file_manager_menu

:pull_from_device
echo.
if "!LANGUAGE!"=="RU" (
    set /p "remote_file=   Файл на устройстве: "
    set /p "local_path=   Локальная папка [%ROOT_DIR%Backups]: "
) else (
    set /p "remote_file=   File on device: "
    set /p "local_path=   Local folder [%ROOT_DIR%Backups]: "
)
if "!local_path!"=="" set "local_path=%ROOT_DIR%Backups"
adb pull "!remote_file!" "!local_path!\" 2>nul && (
    if "!LANGUAGE!"=="RU" (
        echo    Файл скопирован!
    ) else (
        echo    File copied!
    )
) || (
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка копирования!
    ) else (
        echo    Copy error!
    )
)
pause
goto file_manager_menu

:delete_file
echo.
if "!LANGUAGE!"=="RU" (
    set /p "file_to_delete=   Файл для удаления на устройстве: "
    echo    Вы уверены? (y/N): 
) else (
    set /p "file_to_delete=   File to delete on device: "
    echo    Are you sure? (y/N): 
)
set /p "confirm="
if /i "!confirm!"=="y" (
    adb shell "rm -f !file_to_delete!" 2>nul && (
        if "!LANGUAGE!"=="RU" (
            echo    Файл удален!
        ) else (
            echo    File deleted!
        )
    ) || (
        if "!LANGUAGE!"=="RU" (
            echo    Ошибка удаления!
        ) else (
            echo    Delete error!
        )
    )
)
pause
goto file_manager_menu

:create_folder
echo.
if "!LANGUAGE!"=="RU" (
    set /p "new_folder=   Путь к новой папке: "
) else (
    set /p "new_folder=   Path to new folder: "
)
adb shell "mkdir -p !new_folder!" 2>nul && (
    if "!LANGUAGE!"=="RU" (
        echo    Папка создана!
    ) else (
        echo    Folder created!
    )
) || (
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка создания!
    ) else (
        echo    Create error!
    )
)
pause
goto file_manager_menu

:: ================================
:: 12. СБРОС И ФОРМАТИРОВАНИЕ
:: ================================
:wipe_menu
cls
color %COLOR_WARNING%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           СБРОС И ФОРМАТИРОВАНИЕ          #
    echo    #################################################
    echo.
    echo    ВНИМАНИЕ: Опасные операции!
    echo    Могут удалить данные!
) else (
    echo    #################################################
    echo    #           WIPE AND FORMAT                   #
    echo    #################################################
    echo.
    echo    WARNING: Dangerous operations!
    echo    May delete data!
)
echo.
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    [1] Сброс к заводским настройкам
    echo    [2] Форматирование data раздела
    echo    [3] Очистка кэша
    echo    [4] Полная очистка (wipe all)
    echo    [5] Назад
    echo.
    set /p "wipe_choice=   Выберите: "
) else (
    echo    [1] Factory reset
    echo    [2] Format data partition
    echo    [3] Clear cache
    echo    [4] Full wipe (wipe all)
    echo    [5] Back
    echo.
    set /p "wipe_choice=   Select: "
)

if "!wipe_choice!"=="1" goto factory_reset
if "!wipe_choice!"=="2" goto format_data
if "!wipe_choice!"=="3" goto wipe_cache
if "!wipe_choice!"=="4" goto wipe_all
if "!wipe_choice!"=="5" goto main_menu
goto wipe_menu

:factory_reset
echo.
if "!LANGUAGE!"=="RU" (
    echo    ВНИМАНИЕ: Удалит все данные пользователя!
    set /p "confirm=   Введите 'СБРОС' для подтверждения: "
    if /i not "!confirm!"=="СБРОС" goto wipe_menu
) else (
    echo    WARNING: Will delete all user data!
    set /p "confirm=   Enter 'RESET' to confirm: "
    if /i not "!confirm!"=="RESET" goto wipe_menu
)

adb reboot recovery
if "!LANGUAGE!"=="RU" (
    echo    Перезагрузка в Recovery...
    echo    В Recovery выберите: Wipe data/factory reset
) else (
    echo    Rebooting to Recovery...
    echo    In Recovery select: Wipe data/factory reset
)
pause
goto wipe_menu

:format_data
echo.
if "!LANGUAGE!"=="RU" (
    echo    ВНИМАНИЕ: Удалит ВСЕ пользовательские данные!
    set /p "confirm=   Введите 'ФОРМАТ' для подтверждения: "
    if /i not "!confirm!"=="ФОРМАТ" goto wipe_menu
) else (
    echo    WARNING: Will delete ALL user data!
    set /p "confirm=   Enter 'FORMAT' to confirm: "
    if /i not "!confirm!"=="FORMAT" goto wipe_menu
)

adb reboot recovery
if "!LANGUAGE!"=="RU" (
    echo    Перезагрузка в Recovery...
    echo    В Recovery выберите: Format Data
) else (
    echo    Rebooting to Recovery...
    echo    In Recovery select: Format Data
)
pause
goto wipe_menu

:wipe_cache
adb shell "pm clear --cache" >nul 2>&1
if "!LANGUAGE!"=="RU" (
    echo    Кэш очищен!
) else (
    echo    Cache cleared!
)
pause
goto wipe_menu

:wipe_all
echo.
if "!LANGUAGE!"=="RU" (
    echo    ВНИМАНИЕ: Удалит ВСЕ данные и кэш!
    set /p "confirm=   Введите 'УДАЛИТЬ ВСЕ' для подтверждения: "
    if /i not "!confirm!"=="УДАЛИТЬ ВСЕ" goto wipe_menu
) else (
    echo    WARNING: Will delete ALL data and cache!
    set /p "confirm=   Enter 'DELETE ALL' to confirm: "
    if /i not "!confirm!"=="DELETE ALL" goto wipe_menu
)

adb reboot recovery
if "!LANGUAGE!"=="RU" (
    echo    Перезагрузка в Recovery...
    echo    В Recovery выберите: Advanced Wipe -> Select All
) else (
    echo    Rebooting to Recovery...
    echo    In Recovery select: Advanced Wipe -> Select All
)
pause
goto wipe_menu

:: ================================
:: 13. ВОССТАНОВЛЕНИЕ СИСТЕМЫ
:: ================================
:recovery_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ВОССТАНОВЛЕНИЕ СИСТЕМЫ           #
    echo    #################################################
    echo.
    echo    [1] Прошить boot раздел
    echo    [2] Прошить recovery раздел
    echo    [3] Прошить system раздел
    echo    [4] Восстановить из TWRP бэкапа
    echo    [5] Назад
    echo.
    set /p "recovery_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           SYSTEM RECOVERY                   #
    echo    #################################################
    echo.
    echo    [1] Flash boot partition
    echo    [2] Flash recovery partition
    echo    [3] Flash system partition
    echo    [4] Restore from TWRP backup
    echo    [5] Back
    echo.
    set /p "recovery_choice=   Select: "
)

if "!recovery_choice!"=="1" goto flash_boot
if "!recovery_choice!"=="2" goto flash_recovery
if "!recovery_choice!"=="3" goto flash_system
if "!recovery_choice!"=="4" goto restore_twrp
if "!recovery_choice!"=="5" goto main_menu
goto recovery_menu

:flash_boot
echo.
if exist "boot.img" (
    fastboot flash boot boot.img
    if "!LANGUAGE!"=="RU" (
        echo    Boot раздел прошит!
    ) else (
        echo    Boot partition flashed!
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Файл boot.img не найден в текущей папке!
    ) else (
        echo    boot.img file not found in current folder!
    )
)
pause
goto recovery_menu

:flash_recovery
echo.
if exist "recovery.img" (
    fastboot flash recovery recovery.img
    if "!LANGUAGE!"=="RU" (
        echo    Recovery раздел прошит!
    ) else (
        echo    Recovery partition flashed!
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Файл recovery.img не найден!
    ) else (
        echo    recovery.img file not found!
    )
)
pause
goto recovery_menu

:flash_system
echo.
if exist "system.img" (
    if "!LANGUAGE!"=="RU" (
        echo    Прошивка system раздела... (может занять время)
    ) else (
        echo    Flashing system partition... (may take time)
    )
    fastboot flash system system.img
    if "!LANGUAGE!"=="RU" (
        echo    System раздел прошит!
    ) else (
        echo    System partition flashed!
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Файл system.img не найден!
    ) else (
        echo    system.img file not found!
    )
)
pause
goto recovery_menu

:restore_twrp
echo.
if "!LANGUAGE!"=="RU" (
    echo    Для восстановления из TWRP:
    echo    1. Поместите файлы бэкапа в папку TWRP на SD карте
    echo    2. Загрузитесь в TWRP Recovery
    echo    3. Выберите Restore
    echo    4. Выберите бэкап и подтвердите
) else (
    echo    For restore from TWRP:
    echo    1. Place backup files in TWRP folder on SD card
    echo    2. Boot into TWRP Recovery
    echo    3. Select Restore
    echo    4. Select backup and confirm
)
pause
goto recovery_menu

:: ================================
:: 14. ИНФОРМАЦИЯ О ТЕЛЕФОНЕ
:: ================================
:phone_info_menu
cls
color %COLOR_INFO%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ИНФОРМАЦИЯ О ТЕЛЕФОНЕ           #
    echo    #################################################
    echo.
    echo    [1] Быстрая информация
    echo    [2] Все свойства системы
    echo    [3] Информация о батарее
    echo    [4] Информация о памяти
    echo    [5] Список приложений
    echo    [6] Сохранить отчет
    echo    [7] Назад
    echo.
    set /p "info_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           PHONE INFORMATION                 #
    echo    #################################################
    echo.
    echo    [1] Quick information
    echo    [2] All system properties
    echo    [3] Battery information
    echo    [4] Memory information
    echo    [5] App list
    echo    [6] Save report
    echo    [7] Back
    echo.
    set /p "info_choice=   Select: "
)

if "!info_choice!"=="1" goto quick_info
if "!info_choice!"=="2" goto all_props
if "!info_choice!"=="3" goto battery_info
if "!info_choice!"=="4" goto memory_info
if "!info_choice!"=="5" goto apps_list
if "!info_choice!"=="6" goto save_report
if "!info_choice!"=="7" goto main_menu
goto phone_info_menu

:quick_info
echo.
if "!LANGUAGE!"=="RU" (
    echo    === БЫСТРАЯ ИНФОРМАЦИЯ ===
    echo    Модель: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.product.model 2^>nul') do echo    %%i
    echo    Производитель: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.product.manufacturer 2^>nul') do echo    %%i
    echo    Android: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.release 2^>nul') do echo    %%i
    echo    Уровень безопасности: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.security_patch 2^>nul') do echo    %%i
    echo    Устройство: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.product.device 2^>nul') do echo    %%i
) else (
    echo    === QUICK INFORMATION ===
    echo    Model: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.product.model 2^>nul') do echo    %%i
    echo    Manufacturer: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.product.manufacturer 2^>nul') do echo    %%i
    echo    Android: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.release 2^>nul') do echo    %%i
    echo    Security patch: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.security_patch 2^>nul') do echo    %%i
    echo    Device: 
    for /f "tokens=*" %%i in ('adb shell getprop ro.product.device 2^>nul') do echo    %%i
)
pause
goto phone_info_menu

:all_props
echo.
adb shell getprop | more
pause
goto phone_info_menu

:battery_info
echo.
adb shell "dumpsys battery" | findstr /v "DUMP"
pause
goto phone_info_menu

:memory_info
echo.
adb shell "df -h"
echo.
adb shell "free -m"
pause
goto phone_info_menu

:apps_list
echo.
if "!LANGUAGE!"=="RU" (
    echo    [1] Все приложения
    echo    [2] Системные приложения
    echo    [3] Пользовательские приложения
    echo    [4] Назад
    set /p "apps_choice=   Выберите: "
) else (
    echo    [1] All applications
    echo    [2] System applications
    echo    [3] User applications
    echo    [4] Back
    set /p "apps_choice=   Select: "
)

if "!apps_choice!"=="1" (
    adb shell "pm list packages" | more
)
if "!apps_choice!"=="2" (
    adb shell "pm list packages -s" | more
)
if "!apps_choice!"=="3" (
    adb shell "pm list packages -3" | more
)
if "!apps_choice!"=="4" goto phone_info_menu
pause
goto apps_list

:save_report
set "report_file=%ROOT_DIR%Reports\PhoneReport_%date:~6,4%%date:~3,2%%date:~0,2%.txt"
(
if "!LANGUAGE!"=="RU" (
    echo === ОТЧЕТ О ТЕЛЕФОНЕ ===
) else (
    echo === PHONE REPORT ===
)
echo Дата: %date% %time%
echo.
if "!LANGUAGE!"=="RU" (
    echo === ОСНОВНАЯ ИНФОРМАЦИЯ ===
) else (
    echo === BASIC INFORMATION ===
)
for /f "tokens=*" %%i in ('adb shell getprop ro.product.model 2^>nul') do echo Model: %%i
for /f "tokens=*" %%i in ('adb shell getprop ro.product.manufacturer 2^>nul') do echo Manufacturer: %%i
for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.release 2^>nul') do echo Android: %%i
echo.
if "!LANGUAGE!"=="RU" (
    echo === ПАМЯТЬ ===
) else (
    echo === MEMORY ===
)
adb shell "df -h"
echo.
if "!LANGUAGE!"=="RU" (
    echo === БАТАРЕЯ ===
) else (
    echo === BATTERY ===
)
adb shell "dumpsys battery" | findstr /v "DUMP"
) > "!report_file!" 2>nul
if "!LANGUAGE!"=="RU" (
    echo    Отчет сохранен: !report_file!
) else (
    echo    Report saved: !report_file!
)
pause
goto phone_info_menu

:: ================================
:: 15. ОЧИСТКА ПАМЯТИ
:: ================================
:cleanup_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ОЧИСТКА ПАМЯТИ                   #
    echo    #################################################
    echo.
    echo    [1] Очистить кэш всех приложений
    echo    [2] Очистить данные приложений (опасно!)
    echo    [3] Очистить системный кэш
    echo    [4] Очистить временные файлы
    echo    [5] Очистить кэш одного приложения
    echo    [6] Полная очистка
    echo    [7] Назад
    echo.
    set /p "clean_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           MEMORY CLEANUP                    #
    echo    #################################################
    echo.
    echo    [1] Clear all app cache
    echo    [2] Clear app data (dangerous!)
    echo    [3] Clear system cache
    echo    [4] Clear temporary files
    echo    [5] Clear single app cache
    echo    [6] Full cleanup
    echo    [7] Back
    echo.
    set /p "clean_choice=   Select: "
)

if "!clean_choice!"=="1" goto clear_all_cache
if "!clean_choice!"=="2" goto clear_app_data
if "!clean_choice!"=="3" goto clear_system_cache
if "!clean_choice!"=="4" goto clear_temp_files
if "!clean_choice!"=="5" goto clear_single_cache
if "!clean_choice!"=="6" goto full_cleanup
if "!clean_choice!"=="7" goto main_menu
goto cleanup_menu

:clear_all_cache
echo.
if "!LANGUAGE!"=="RU" (
    echo    Очистка кэша всех приложений...
) else (
    echo    Clearing all app cache...
)
set /a count=0
for /f "tokens=2 delims=:" %%a in ('adb shell "pm list packages" 2^>nul') do (
    set "package=%%a"
    set "package=!package:~1!"
    adb shell "pm clear !package!" >nul 2>&1 && set /a count+=1
)
if "!LANGUAGE!"=="RU" (
    echo    Очищено: !count! приложений
) else (
    echo    Cleared: !count! applications
)
pause
goto cleanup_menu

:clear_app_data
echo.
if "!LANGUAGE!"=="RU" (
    echo    ВНИМАНИЕ: Удалит все данные приложений!
    set /p "confirm=   Введите 'ДА' для подтверждения: "
    if /i not "!confirm!"=="ДА" goto cleanup_menu
    echo    Очистка данных приложений...
) else (
    echo    WARNING: Will delete all app data!
    set /p "confirm=   Enter 'YES' to confirm: "
    if /i not "!confirm!"=="YES" goto cleanup_menu
    echo    Clearing app data...
)
for /f "tokens=2 delims=:" %%a in ('adb shell "pm list packages -3" 2^>nul') do (
    set "package=%%a"
    set "package=!package:~1!"
    adb shell "pm clear !package!" >nul 2>&1
)
if "!LANGUAGE!"=="RU" (
    echo    Данные очищены!
) else (
    echo    Data cleared!
)
pause
goto cleanup_menu

:clear_system_cache
echo.
if "!LANGUAGE!"=="RU" (
    echo    Очистка системного кэша...
) else (
    echo    Clearing system cache...
)
adb shell "rm -rf /cache/*" >nul 2>&1
adb shell "rm -rf /data/local/tmp/*" >nul 2>&1
if "!LANGUAGE!"=="RU" (
    echo    Системный кэш очищен!
) else (
    echo    System cache cleared!
)
pause
goto cleanup_menu

:clear_temp_files
echo.
if "!LANGUAGE!"=="RU" (
    echo    Очистка временных файлов...
) else (
    echo    Clearing temporary files...
)
adb shell "find /sdcard -name '*.tmp' -delete" >nul 2>&1
adb shell "find /sdcard -name '*.temp' -delete" >nul 2>&1
adb shell "find /sdcard -name '*.log' -size +1M -delete" >nul 2>&1
if "!LANGUAGE!"=="RU" (
    echo    Временные файлы очищены!
) else (
    echo    Temporary files cleared!
)
pause
goto cleanup_menu

:clear_single_cache
echo.
if "!LANGUAGE!"=="RU" (
    set /p "package_name=   Имя пакета приложения: "
) else (
    set /p "package_name=   App package name: "
)
if "!package_name!"=="" goto cleanup_menu

adb shell "pm clear !package_name!" 2>nul
if errorlevel 1 (
    if "!LANGUAGE!"=="RU" (
        echo    Ошибка очистки!
    ) else (
        echo    Clear error!
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Кэш приложения очищен!
    ) else (
        echo    App cache cleared!
    )
)
pause
goto cleanup_menu

:full_cleanup
echo.
if "!LANGUAGE!"=="RU" (
    echo    ВНИМАНИЕ: Полная очистка системы!
    set /p "confirm=   Введите 'ОЧИСТИТЬ' для подтверждения: "
    if /i not "!confirm!"=="ОЧИСТИТЬ" goto cleanup_menu
    call :clear_all_cache
    call :clear_system_cache
    call :clear_temp_files
    echo    Полная очистка завершена!
) else (
    echo    WARNING: Full system cleanup!
    set /p "confirm=   Enter 'CLEAN' to confirm: "
    if /i not "!confirm!"=="CLEAN" goto cleanup_menu
    call :clear_all_cache
    call :clear_system_cache
    call :clear_temp_files
    echo    Full cleanup completed!
)
pause
goto cleanup_menu

:: ================================
:: 16. НАСТРОЙКИ ПРОГРАММЫ
:: ================================
:program_settings
cls
color %COLOR_INFO%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           НАСТРОЙКИ ПРОГРАММЫ             #
    echo    #################################################
    echo.
    echo    [1] Изменить цветовую схему
    echo    [2] Изменить путь к ADB
    echo    [3] Установить папки для бэкапов
    echo    [4] Изменить язык
    echo    [5] Информация о системе
    echo    [6] Сброс настроек
    echo    [7] Назад
    echo.
    set /p "settings_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           PROGRAM SETTINGS                  #
    echo    #################################################
    echo.
    echo    [1] Change color scheme
    echo    [2] Change ADB path
    echo    [3] Set backup folders
    echo    [4] Change language
    echo    [5] System information
    echo    [6] Reset settings
    echo    [7] Back
    echo.
    set /p "settings_choice=   Select: "
)

if "!settings_choice!"=="1" goto change_colors
if "!settings_choice!"=="2" goto change_adb_path
if "!settings_choice!"=="3" goto change_folders
if "!settings_choice!"=="4" goto change_language
if "!settings_choice!"=="5" goto system_info
if "!settings_choice!"=="6" goto reset_settings
if "!settings_choice!"=="7" goto main_menu
goto program_settings

:change_colors
echo.
if "!LANGUAGE!"=="RU" (
    echo    Текущие цвета:
    echo    Нормальный: %COLOR_NORMAL%
    echo    Успех: %COLOR_SUCCESS%
    echo    Ошибка: %COLOR_ERROR%
    echo.
    set /p "new_color=   Новый цвет для нормального [%COLOR_NORMAL%]: "
) else (
    echo    Current colors:
    echo    Normal: %COLOR_NORMAL%
    echo    Success: %COLOR_SUCCESS%
    echo    Error: %COLOR_ERROR%
    echo.
    set /p "new_color=   New color for normal [%COLOR_NORMAL%]: "
)
if not "!new_color!"=="" (
    set "COLOR_NORMAL=!new_color!"
    call :save_config "COLOR_NORMAL" "!COLOR_NORMAL!"
    if "!LANGUAGE!"=="RU" (
        echo    Цвет изменен!
    ) else (
        echo    Color changed!
    )
)
pause
goto program_settings

:change_adb_path
echo.
if "!LANGUAGE!"=="RU" (
    set /p "new_adb_path=   Новый путь к ADB: "
) else (
    set /p "new_adb_path=   New ADB path: "
)
if exist "!new_adb_path!\adb.exe" (
    set "ADB_PATH=!new_adb_path!"
    set "SAVED_ADB_PATH=!new_adb_path!"
    set "USER_ADB_PATH=!new_adb_path!"  :: ИСПРАВЛЕНО: сохраняем и в USER_ADB_PATH
    call :save_config "SAVED_ADB_PATH" "!new_adb_path!"
    call :save_config "USER_ADB_PATH" "!new_adb_path!"
    if "!LANGUAGE!"=="RU" (
        echo    Путь к ADB изменен!
    ) else (
        echo    ADB path changed!
    )
) else (
    if "!LANGUAGE!"=="RU" (
        echo    ADB не найден по указанному пути!
    ) else (
        echo    ADB not found in specified path!
    )
)
pause
goto program_settings

:change_folders
echo.
if "!LANGUAGE!"=="RU" (
    echo    Текущая папка для бэкапов: %ROOT_DIR%Backups
    set /p "new_backup=   Новая папка для бэкапов: "
) else (
    echo    Current backup folder: %ROOT_DIR%Backups
    set /p "new_backup=   New backup folder: "
)
if not "!new_backup!"=="" (
    set "BACKUP_FOLDER=!new_backup!"
    mkdir "!new_backup!" 2>nul
    call :save_config "BACKUP_FOLDER" "!BACKUP_FOLDER!"
    if "!LANGUAGE!"=="RU" (
        echo    Папка для бэкапов изменена!
    ) else (
        echo    Backup folder changed!
    )
)
pause
goto program_settings

:change_language
echo.
if "!LANGUAGE!"=="RU" (
    echo    Текущий язык: Русский
    echo.
    echo    Выберите язык:
    echo    [1] Русский (RU)
    echo    [2] English (EN)
    echo    [3] Назад
    echo.
    set /p "lang_choice=   Выберите: "
) else (
    echo    Current language: English
    echo.
    echo    Select language:
    echo    [1] Русский (RU)
    echo    [2] English (EN)
    echo    [3] Back
    echo.
    set /p "lang_choice=   Select: "
)

if "!lang_choice!"=="1" (
    set "LANGUAGE=RU"
    call :save_config "LANGUAGE" "RU"
    cls
    if "!LANGUAGE!"=="RU" (
        echo    Язык изменен на Русский!
        echo    Программа перезагружается...
    ) else (
        echo    Language changed to Russian!
        echo    Program reloading...
    )
    timeout /t 2 >nul
    :: ПЕРЕЗАГРУЗКА ПРОГРАММЫ - ИСПРАВЛЕНО
    "%ROOT_DIR%%~nx0"
    exit
)
if "!lang_choice!"=="2" (
    set "LANGUAGE=EN"
    call :save_config "LANGUAGE" "EN"
    cls
    if "!LANGUAGE!"=="RU" (
        echo    Язык изменен на Английский!
        echo    Программа перезагружается...
    ) else (
        echo    Language changed to English!
        echo    Program reloading...
    )
    timeout /t 2 >nul
    :: ПЕРЕЗАГРУЗКА ПРОГРАММЫ - ИСПРАВЛЕНО
    "%ROOT_DIR%%~nx0"
    exit
)
if "!lang_choice!"=="3" goto program_settings
goto change_language

:system_info
echo.
if "!LANGUAGE!"=="RU" (
    echo    === ИНФОРМАЦИЯ О СИСТЕМЕ ===
    echo    Папка программы: %ROOT_DIR%
    echo    ADB путь: !ADB_PATH!
    echo    Конфиг файл: !CONFIG_FILE!
    echo    Лог файл: !LOG_FILE!
    echo    Язык: !LANGUAGE!
    if defined USER_ADB_PATH echo    Пользовательский путь ADB: !USER_ADB_PATH!
) else (
    echo    === SYSTEM INFORMATION ===
    echo    Program folder: %ROOT_DIR%
    echo    ADB path: !ADB_PATH!
    echo    Config file: !CONFIG_FILE!
    echo    Log file: !LOG_FILE!
    echo    Language: !LANGUAGE!
    if defined USER_ADB_PATH echo    User ADB path: !USER_ADB_PATH!
)
echo.
pause
goto program_settings

:reset_settings
echo.
if "!LANGUAGE!"=="RU" (
    echo    ВНИМАНИЕ: Все настройки будут сброшены!
    set /p "confirm=   Введите 'СБРОС' для подтверждения: "
    if /i not "!confirm!"=="СБРОС" goto program_settings
    
    echo    Сброс настроек...
    del "!CONFIG_FILE!" 2>nul
    echo    Настройки сброшены! Программа перезагружается...
    timeout /t 2 >nul
    :: ПЕРЕЗАГРУЗКА ПРОГРАММЫ - ИСПРАВЛЕНО
    "%ROOT_DIR%%~nx0"
    exit
) else (
    echo    WARNING: All settings will be reset!
    set /p "confirm=   Enter 'RESET' to confirm: "
    if /i not "!confirm!"=="RESET" goto program_settings
    
    echo    Resetting settings...
    del "!CONFIG_FILE!" 2>nul
    echo    Settings reset! Program reloading...
    timeout /t 2 >nul
    :: ПЕРЕЗАГРУЗКА ПРОГРАММЫ - ИСПРАВЛЕНО
    "%ROOT_DIR%%~nx0"
    exit
)

:: ================================
:: 17. УТИЛИТЫ И ИНСТРУМЕНТЫ
:: ================================
:utilities_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           УТИЛИТЫ И ИНСТРУМЕНТЫ           #
    echo    #################################################
    echo.
    echo    [1] Создать скрипт ADB
    echo    [2] Просмотр логов программы
    echo    [3] Очистка кэша программы
    echo    [4] Проверка обновлений ADB
    echo    [5] Тест соединения
    echo    [6] Назад
    echo.
    set /p "util_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           UTILITIES AND TOOLS               #
    echo    #################################################
    echo.
    echo    [1] Create ADB script
    echo    [2] View program logs
    echo    [3] Clear program cache
    echo    [4] Check ADB updates
    echo    [5] Test connection
    echo    [6] Back
    echo.
    set /p "util_choice=   Select: "
)

if "!util_choice!"=="1" goto create_script
if "!util_choice!"=="2" goto view_logs
if "!util_choice!"=="3" goto clear_prog_cache
if "!util_choice!"=="4" goto check_updates
if "!util_choice!"=="5" goto test_connection
if "!util_choice!"=="6" goto main_menu
goto utilities_menu

:create_script
echo.
if "!LANGUAGE!"=="RU" (
    set /p "script_name=   Имя скрипта: "
) else (
    set /p "script_name=   Script name: "
)
if "!script_name!"=="" goto utilities_menu

set "script_file=%ROOT_DIR%Scripts\!script_name!.bat"
echo @echo off > "!script_file!"
echo chcp 65001 >nul >> "!script_file!"
echo echo Скрипт создан FluffyHub Toolbox >> "!script_file!"
echo.
if "!LANGUAGE!"=="RU" (
    echo    Скрипт создан: !script_file!
) else (
    echo    Script created: !script_file!
)
notepad "!script_file!"
pause
goto utilities_menu

:view_logs
if exist "!LOG_FILE!" (
    notepad "!LOG_FILE!"
) else (
    if "!LANGUAGE!"=="RU" (
        echo    Лог файл не найден!
    ) else (
        echo    Log file not found!
    )
)
pause
goto utilities_menu

:clear_prog_cache
echo.
del /q "%ROOT_DIR%Temp\*.*" 2>nul
del /q "%ROOT_DIR%Cache\*.*" 2>nul
if "!LANGUAGE!"=="RU" (
    echo    Кэш программы очищен!
) else (
    echo    Program cache cleared!
)
pause
goto utilities_menu

:check_updates
echo.
if "!LANGUAGE!"=="RU" (
    echo    Проверка обновлений ADB...
) else (
    echo    Checking ADB updates...
)
adb version
echo.
if "!LANGUAGE!"=="RU" (
    echo    Для обновления:
    echo    1. Скачайте platform-tools с сайта Google
    echo    2. Замените файлы в папке: !ADB_PATH!
) else (
    echo    For update:
    echo    1. Download platform-tools from Google site
    echo    2. Replace files in folder: !ADB_PATH!
)
pause
goto utilities_menu

:test_connection
echo.
if "!LANGUAGE!"=="RU" (
    echo    Тест соединения ADB...
) else (
    echo    ADB connection test...
)
adb devices
echo.
if "!LANGUAGE!"=="RU" (
    echo    Тест Fastboot...
) else (
    echo    Fastboot test...
)
fastboot devices
echo.
pause
goto utilities_menu

:: ================================
:: 18. О ПРОГРАММЕ
:: ================================
:about_menu
cls
color %COLOR_HIGHLIGHT%
echo    #################################################
echo    #           FLUFFYHUB TOOLBOX 2025            #
echo    #               by kotikxD                    #
echo    #################################################
echo.
if "!LANGUAGE!"=="RU" (
    echo    Версия: 2.5 MultiLang
    echo    Дата сборки: 2025
    echo.
    echo    Функции:
    echo    • Работа с ADB и Fastboot
    echo    • Управление Android устройствами
    echo    • Бэкап и восстановление
    echo    • Очистка и оптимизация
    echo    • Инструменты для разработчиков
    echo    • Поддержка русского и английского
    echo.
    echo    Контакты:
    echo    • GitHub: github.com/FluffyKotikxD
    echo    • Telegram: @FluffyHubDevelopers
    echo.
    echo    Лицензия: MIT Open Source
) else (
    echo    Version: 2.5 MultiLang
    echo    Build date: 2025
    echo.
    echo    Features:
    echo    • ADB and Fastboot operations
    echo    • Android device management
    echo    • Backup and recovery
    echo    • Cleanup and optimization
    echo    • Developer tools
    echo    • Russian and English support
    echo.
    echo    Contacts:
    echo    • GitHub: github.com/FluffyKotikxD
    echo    • Telegram: @FluffyHubDevelopers
    echo.
    echo    License: MIT Open Source
)
echo.
pause
goto main_menu

:: ================================
:: 19. ВЫХОД
:: ================================
:exit_prog
cls
color %COLOR_NORMAL%
echo.
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           СПАСИБО ЗА ИСПОЛЬЗОВАНИЕ        #
    echo    #           FLUFFYHUB TOOLBOX 2025            #
    echo    #               by kotikxD                    #
    echo    #################################################
) else (
    echo    #################################################
    echo    #           THANK YOU FOR USING              #
    echo    #           FLUFFYHUB TOOLBOX 2025            #
    echo    #               by kotikxD                    #
    echo    #################################################
)
echo.
echo [%time%] === FluffyHub Toolbox Closed === >> "%LOG_FILE%"
timeout /t 2 >nul
exit

:: ================================
:: ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
:: ================================

:save_config
set "param=%~1"
set "value=%~2"
if not exist "!CONFIG_FILE!" (
    echo # FluffyHub Toolbox Configuration > "!CONFIG_FILE!"
    echo # Generated: %date% %time% >> "!CONFIG_FILE!"
    echo. >> "!CONFIG_FILE!"
)

:: Создаем временный файл
set "temp_config=%ROOT_DIR%Temp\config.tmp"
copy "!CONFIG_FILE!" "!temp_config!" >nul 2>&1
del "!CONFIG_FILE!" 2>nul

set "found=0"
for /f "usebackq tokens=1,* delims==" %%a in ("!temp_config!") do (
    if "%%a"=="!param!" (
        echo !param!=!value! >> "!CONFIG_FILE!"
        set "found=1"
    ) else if not "%%a"=="" (
        echo %%a=%%b >> "!CONFIG_FILE!"
    )
)

if !found!==0 echo !param!=!value! >> "!CONFIG_FILE!"
del "!temp_config!" 2>nul
exit /b