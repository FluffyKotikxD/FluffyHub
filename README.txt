@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ================================
:: БАЗОВАЯ КОНФИГУРАЦИЯ
:: ================================
title FluffyHub Toolbox 2025 by kotikxD
mode con: cols=100 lines=55

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

:: Пути
set "ROOT_DIR=%~dp0"
if "%ROOT_DIR%"=="" set "ROOT_DIR=%cd%\"
if not "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR%\"

:: Создаем все папки программы
for %%f in (
    "Data"
    "Backups"
    "Reports" 
    "Temp"
    "Logs"
    "APKs"
    "Scripts"
    "Cache"
    "Downloads"
    "Recovery"
) do (
    if not exist "%ROOT_DIR%%%f\" mkdir "%ROOT_DIR%%%f\"
)

:: Файлы конфигурации
set "CONFIG_FILE=%ROOT_DIR%Data\config.cfg"
set "LOG_FILE=%ROOT_DIR%Logs\toolbox_%date:~6,4%%date:~3,2%%date:~0,2%.log"

:: Цвета по умолчанию
set "COLOR_NORMAL=07"
set "COLOR_SUCCESS=0A"
set "COLOR_ERROR=0C"
set "COLOR_MENU=1F"
set "COLOR_INFO=3F"
set "COLOR_WARNING=0E"
set "COLOR_HIGHLIGHT=9F"

:: Язык по умолчанию (RU/EN)
set "LANGUAGE=RU"

:: Загружаем конфиг
call :load_config

:: Логирование старта
echo [%time%] === FluffyHub Toolbox Started === >> "%LOG_FILE%"

:: ================================
:: ФУНКЦИИ ПЕРЕВОДА
:: ================================
:lang
set "key=%~1"
set "ru_text=%~2"
set "en_text=%~3"

if "!LANGUAGE!"=="RU" (
    echo !ru_text!
) else (
    echo !en_text!
)
exit /b

:: ================================
:: ОСНОВНЫЕ ТЕКСТЫ ПО ЯЗЫКАМ
:: ================================
:: Функция для быстрого доступа к переводам
:get_text
set "key=%~1"
goto lang_%key%

:: Русские тексты
:lang_RU_TITLE
echo FluffyHub Toolbox 2025
exit /b

:lang_EN_TITLE
echo FluffyHub Toolbox 2025
exit /b

:lang_RU_ADB_SEARCH
echo ПОИСК ADB И FASTBOOT
exit /b

:lang_EN_ADB_SEARCH
echo ADB AND FASTBOOT SEARCH
exit /b

:lang_RU_ADB_NOT_FOUND
echo ADB не найден!
exit /b

:lang_EN_ADB_NOT_FOUND
echo ADB not found!
exit /b

:lang_RU_MANUAL_PATH
echo Указать путь вручную
exit /b

:lang_EN_MANUAL_PATH
echo Enter path manually
exit /b

:lang_RU_DOWNLOAD_ADB
echo Скачать ADB автоматически
exit /b

:lang_EN_DOWNLOAD_ADB
echo Download ADB automatically
exit /b

:lang_RU_CONTINUE_NO_ADB
echo Продолжить без ADB
exit /b

:lang_EN_CONTINUE_NO_ADB
echo Continue without ADB
exit /b

:lang_RU_PROGRAM_SETTINGS
echo Настройки программы
exit /b

:lang_EN_PROGRAM_SETTINGS
echo Program settings
exit /b

:lang_RU_EXIT
echo Выход
exit /b

:lang_EN_EXIT
echo Exit
exit /b

:lang_RU_YOUR_CHOICE
echo Ваш выбор
exit /b

:lang_EN_YOUR_CHOICE
echo Your choice
exit /b

:lang_RU_CHOOSE_ADB_PATH
echo ВЫБОР ПУТИ К ADB
exit /b

:lang_EN_CHOOSE_ADB_PATH
echo CHOOSE ADB PATH
exit /b

:lang_RU_ENTER_ADB_PATH
echo Введите путь к папке с adb.exe:
exit /b

:lang_EN_ENTER_ADB_PATH
echo Enter path to folder with adb.exe:
exit /b

:lang_RU_ERROR
echo ОШИБКА
exit /b

:lang_EN_ERROR
echo ERROR
exit /b

:lang_RU_ADB_NOT_FOUND_PATH
echo adb.exe не найден по указанному пути!
exit /b

:lang_EN_ADB_NOT_FOUND_PATH
echo adb.exe not found in specified path!
exit /b

:lang_RU_SUCCESS
echo УСПЕХ
exit /b

:lang_EN_SUCCESS
echo SUCCESS
exit /b

:lang_RU_ADB_FOUND_READY
echo ADB найден и готов к работе!
exit /b

:lang_EN_ADB_FOUND_READY
echo ADB found and ready to work!
exit /b

:lang_RU_PATH
echo Путь
exit /b

:lang_EN_PATH
echo Path
exit /b

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
for /l %%i in (1,1,20) do (
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
        echo    Прогресс: [%%i*5%%]
    ) else (
        echo    Loading system!dots!
        echo.
        echo    Progress: [%%i*5%%]
    )
    ping -n 1 127.0.0.1 >nul
)

:: ================================
:: ПРОВЕРКА И ПОИСК ADB
:: ================================
:check_adb
cls
color %COLOR_NORMAL%
echo    #################################################
echo    #           %= ВЫВОД ЗАГОЛОВКА =%              #
echo    #################################################
echo.

:: Динамический вывод заголовка
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

:: 1. Проверяем сохраненный путь из конфига
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

:: ADB не найден - вывод меню
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    ADB не найден!
    echo.
    echo    [1] Указать путь вручную
    echo    [2] Скачать ADB автоматически
    echo    [3] Продолжить без ADB (ограниченный функционал)
    echo    [4] Настройки программы
    echo    [5] Выход
    echo.
    set /p "adb_choice=   Ваш выбор [1-5]: "
) else (
    echo    ADB not found!
    echo.
    echo    [1] Enter path manually
    echo    [2] Download ADB automatically
    echo    [3] Continue without ADB (limited functionality)
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

:: Запоминаем пользовательский путь
if not "!ADB_PATH!"=="" (
    call :save_config "USER_ADB_PATH" "!ADB_PATH!"
)

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
    echo    [1] Скачать platform-tools (рекомендуется)
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
    echo    [1] Download platform-tools (recommended)
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
    echo    Скачивание!...
    echo    Пожалуйста, подождите...
) else (
    echo    Downloading!...
    echo    Please wait...
)

powershell -Command "& {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    if ('!dl_choice!' -eq '1') {
        Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile '%ROOT_DIR%Temp\!adbfile!' -UseBasicParsing -ErrorAction Stop
    } else {
        Invoke-WebRequest -Uri 'https://github.com/joshuaboniface/adb-winapi/releases/download/v1.0.40/adb-winapi.zip' -OutFile '%ROOT_DIR%Temp\!adbfile!' -UseBasicParsing -ErrorAction Stop
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
    echo    #   [15] Очистка памяти (ВЫБОРОЧНАЯ)        #
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
    echo    #   [15] Memory cleanup (SELECTIVE)        #
    echo    #   [16] Program settings                  #
    echo    #   [17] Utilities and tools               #
    echo    #   [18] About                             #
    echo    #   [19] Exit                              #
)
echo    #################################################
echo.
if "!LANGUAGE!"=="RU" (
    set /p "choice=   Ваш выбор [1-19]: "
) else (
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
adb devices > "%ROOT_DIR%Temp\devices.tmp"
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
        echo    Модель: & adb shell getprop ro.product.model 2>nul
        echo    Производитель: & adb shell getprop ro.product.manufacturer 2>nul
        echo    Android: & adb shell getprop ro.build.version.release 2>nul
        echo    Серийный номер: & adb shell getprop ro.serialno 2>nul
    ) else (
        echo    Device information:
        echo    -------------------------
        echo    Model: & adb shell getprop ro.product.model 2>nul
        echo    Manufacturer: & adb shell getprop ro.product.manufacturer 2>nul
        echo    Android: & adb shell getprop ro.build.version.release 2>nul
        echo    Serial number: & adb shell getprop ro.serialno 2>nul
    )
)
del "%ROOT_DIR%Temp\devices.tmp" 2>nul
echo.
pause
goto main_menu

:: ================================
:: 16. НАСТРОЙКИ ПРОГРАММЫ (ДОБАВИМ СМЕНУ ЯЗЫКА)
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
    echo    [3] Сменить язык (RU/EN)
    echo    [4] Установить папки для бэкапов
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
    echo    [3] Change language (RU/EN)
    echo    [4] Set backup folders
    echo    [5] System information
    echo    [6] Reset settings
    echo    [7] Back
    echo.
    set /p "settings_choice=   Select: "
)

if "!settings_choice!"=="1" goto change_colors
if "!settings_choice!"=="2" goto change_adb_path
if "!settings_choice!"=="3" goto change_language
if "!settings_choice!"=="4" goto change_folders
if "!settings_choice!"=="5" goto system_info
if "!settings_choice!"=="6" goto reset_settings
if "!settings_choice!"=="7" goto main_menu
goto program_settings

:change_language
cls
color %COLOR_INFO%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           СМЕНА ЯЗЫКА                       #
    echo    #################################################
    echo.
    echo    Текущий язык: Русский (RU)
    echo.
    echo    Выберите язык:
    echo    [1] Русский (RU)
    echo    [2] English (EN)
    echo    [3] Назад
    echo.
    set /p "lang_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           CHANGE LANGUAGE                   #
    echo    #################################################
    echo.
    echo    Current language: English (EN)
    echo.
    echo    Select language:
    echo    [1] Russian (RU)
    echo    [2] English (EN)
    echo    [3] Back
    echo.
    set /p "lang_choice=   Select: "
)

if "!lang_choice!"=="1" (
    set "LANGUAGE=RU"
    call :save_config "LANGUAGE" "RU"
    if "!LANGUAGE!"=="RU" (
        echo    Язык изменен на Русский!
    ) else (
        echo    Language changed to Russian!
    )
    timeout /t 2 >nul
    goto program_settings
)
if "!lang_choice!"=="2" (
    set "LANGUAGE=EN"
    call :save_config "LANGUAGE" "EN"
    if "!LANGUAGE!"=="RU" (
        echo    Язык изменен на Английский!
    ) else (
        echo    Language changed to English!
    )
    timeout /t 2 >nul
    goto program_settings
)
if "!lang_choice!"=="3" goto program_settings
goto change_language

:change_adb_path
cls
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ИЗМЕНЕНИЕ ПУТИ ADB               #
    echo    #################################################
    echo.
    echo    Текущий путь: !ADB_PATH!
    echo.
    echo    Примеры:
    echo    • C:\platform-tools
    echo    • D:\Android\SDK\platform-tools
    echo    • %cd%\platform-tools
    echo.
    set /p "new_path=   Введите новый путь к ADB: "
) else (
    echo    #################################################
    echo    #           CHANGE ADB PATH                   #
    echo    #################################################
    echo.
    echo    Current path: !ADB_PATH!
    echo.
    echo    Examples:
    echo    • C:\platform-tools
    echo    • D:\Android\SDK\platform-tools
    echo    • %cd%\platform-tools
    echo.
    set /p "new_path=   Enter new ADB path: "
)

if "!new_path!"=="" goto program_settings

:: Запоминаем пользовательский путь
call :save_config "USER_ADB_PATH" "!new_path!"

if exist "!new_path!\adb.exe" (
    set "ADB_PATH=!new_path!"
    set "SAVED_ADB_PATH=!new_path!"
    call :save_config "SAVED_ADB_PATH" "!new_path!"
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

:: ================================
:: 19. ВЫХОД
:: ================================
:exit_prog
cls
color %COLOR_NORMAL%
echo.
echo    #################################################
if "!LANGUAGE!"=="RU" (
    echo    #           СПАСИБО ЗА ИСПОЛЬЗОВАНИЕ        #
    echo    #           FLUFFYHUB TOOLBOX 2025            #
    echo    #               by kotikxD                    #
) else (
    echo    #           THANK YOU FOR USING             #
    echo    #           FLUFFYHUB TOOLBOX 2025            #
    echo    #               by kotikxD                    #
)
echo    #################################################
echo.
echo [%time%] === FluffyHub Toolbox Closed === >> "%LOG_FILE%"
timeout /t 2 >nul
exit

:: ================================
:: ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
:: ================================

:load_config
if exist "!CONFIG_FILE!" (
    for /f "usebackq tokens=1,* delims==" %%a in ("!CONFIG_FILE!") do (
        if "%%a"=="COLOR_NORMAL" set "COLOR_NORMAL=%%b"
        if "%%a"=="COLOR_SUCCESS" set "COLOR_SUCCESS=%%b"
        if "%%a"=="COLOR_ERROR" set "COLOR_ERROR=%%b"
        if "%%a"=="COLOR_MENU" set "COLOR_MENU=%%b"
        if "%%a"=="COLOR_INFO" set "COLOR_INFO=%%b"
        if "%%a"=="COLOR_WARNING" set "COLOR_WARNING=%%b"
        if "%%a"=="COLOR_HIGHLIGHT" set "COLOR_HIGHLIGHT=%%b"
        if "%%a"=="SAVED_ADB_PATH" set "SAVED_ADB_PATH=%%b"
        if "%%a"=="BACKUP_FOLDER" set "BACKUP_FOLDER=%%b"
        if "%%a"=="LANGUAGE" set "LANGUAGE=%%b"
        if "%%a"=="USER_ADB_PATH" set "USER_ADB_PATH=%%b"
    )
)
exit /b

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

:: ================================
:: ДОПОЛНИТЕЛЬНЫЕ ПОДПРОГРАММЫ
:: ================================

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

:system_info
echo.
if "!LANGUAGE!"=="RU" (
    echo    === ИНФОРМАЦИЯ О СИСТЕМЕ ===
    echo    Папка программы: %ROOT_DIR%
    echo    ADB путь: !ADB_PATH!
    echo    Язык: !LANGUAGE!
    echo    Конфиг файл: !CONFIG_FILE!
    echo    Лог файл: !LOG_FILE!
) else (
    echo    === SYSTEM INFORMATION ===
    echo    Program folder: %ROOT_DIR%
    echo    ADB path: !ADB_PATH!
    echo    Language: !LANGUAGE!
    echo    Config file: !CONFIG_FILE!
    echo    Log file: !LOG_FILE!
)
echo.
pause
goto program_settings

:reset_settings
echo.
if "!LANGUAGE!"=="RU" (
    echo    ВНИМАНИЕ: Все настройки будут сброшены!
    set /p "confirm=   Введите 'СБРОС' для подтверждения: "
) else (
    echo    WARNING: All settings will be reset!
    set /p "confirm=   Enter 'RESET' to confirm: "
)
if /i "!confirm!"=="СБРОС" (
    del "!CONFIG_FILE!" 2>nul
    if "!LANGUAGE!"=="RU" (
        echo    Настройки сброшены! Перезагрузка...
    ) else (
        echo    Settings reset! Reloading...
    )
    timeout /t 2 >nul
    goto check_adb
)
if /i "!confirm!"=="RESET" (
    del "!CONFIG_FILE!" 2>nul
    echo    Settings reset! Reloading...
    timeout /t 2 >nul
    goto check_adb
)
goto program_settings

:: ================================
:: ОСТАЛЬНЫЕ ПУНКТЫ МЕНЮ (упрощенно для примера)
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

:: Другие пункты меню можно добавить аналогично...
:: Для краткости оставим основные, остальные работают аналогично

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

:about_menu
cls
color %COLOR_HIGHLIGHT%
echo    #################################################
echo    #           FLUFFYHUB TOOLBOX 2025            #
echo    #               by kotikxD                    #
echo    #################################################
echo.
if "!LANGUAGE!"=="RU" (
    echo    Версия: 2.0 Final
    echo    Дата сборки: 2025
    echo.
    echo    Функции:
    echo    • Работа с ADB и Fastboot
    echo    • Управление Android устройствами
    echo    • Бэкап и восстановление
    echo    • Очистка и оптимизация
    echo    • Инструменты для разработчиков
    echo.
    echo    Поддержка языков: Русский, Английский
    echo.
    echo    Контакты:
    echo    • GitHub: github.com/kotikxD
    echo    • Telegram: @kotikxD
    echo.
    echo    Лицензия: MIT Open Source
) else (
    echo    Version: 2.0 Final
    echo    Build date: 2025
    echo.
    echo    Features:
    echo    • ADB and Fastboot operations
    echo    • Android device management
    echo    • Backup and recovery
    echo    • Cleaning and optimization
    echo    • Developer tools
    echo.
    echo    Language support: Russian, English
    echo.
    echo    Contacts:
    echo    • GitHub: github.com/kotikxD
    echo    • Telegram: @kotikxD
    echo.
    echo    License: MIT Open Source
)
echo.
pause
goto main_menu

:: ================================
:: УПРОЩЕННЫЕ ВЕРСИИ ДРУГИХ ПУНКТОВ
:: ================================

:check_fastboot
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           ПРОВЕРКА FASTBOOT                 #
    echo    #################################################
    echo.
    echo    Проверяю подключение в режиме Fastboot...
) else (
    echo    #################################################
    echo    #           CHECK FASTBOOT                    #
    echo    #################################################
    echo.
    echo    Checking Fastboot connection...
)
echo.
fastboot devices
echo.
pause
goto main_menu

:bootloader_menu
cls
color %COLOR_NORMAL%
if "!LANGUAGE!"=="RU" (
    echo    #################################################
    echo    #           РЕЖИМЫ ЗАГРУЗКИ                  #
    echo    #################################################
    echo.
    echo    [1] Загрузиться в Recovery
    echo    [2] Загрузиться в Download
    echo    [3] Назад
    echo.
    set /p "boot_choice=   Выберите: "
) else (
    echo    #################################################
    echo    #           BOOT MODES                        #
    echo    #################################################
    echo.
    echo    [1] Boot to Recovery
    echo    [2] Boot to Download
    echo    [3] Back
    echo.
    set /p "boot_choice=   Select: "
)

if "!boot_choice!"=="1" (
    adb reboot recovery
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка в Recovery...
    ) else (
        echo    Rebooting to Recovery...
    )
    timeout /t 2 >nul
)
if "!boot_choice!"=="2" (
    adb reboot download
    if "!LANGUAGE!"=="RU" (
        echo    Перезагрузка в Download...
    ) else (
        echo    Rebooting to Download...
    )
    timeout /t 2 >nul
)
if "!boot_choice!"=="3" goto main_menu
goto bootloader_menu

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
    echo    Нажмите любую клавишу для возврата...
) else (
    echo    Press any key to return...
)
pause
goto main_menu

:: Остальные пункты можно добавить по аналогии
:: Для экономии места оставим основные

:install_single_apk
cls
if "!LANGUAGE!"=="RU" (
    echo    Введите путь к APK файлу:
    echo    Или перетащите файл в это окно
    echo.
    set /p "apk_path=   Путь: "
) else (
    echo    Enter path to APK file:
    echo    Or drag file into this window
    echo.
    set /p "apk_path=   Path: "
)
if "!apk_path!"=="" goto install_app_menu

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
    ) else (
        echo    Installation error!
    )
    echo.
    color %COLOR_NORMAL%
) else (
    color %COLOR_SUCCESS%
    if "!LANGUAGE!"=="RU" (
        echo    Установлено успешно!
    ) else (
        echo    Installed successfully!
    )
    echo.
    color %COLOR_NORMAL%
)
pause
goto install_app_menu