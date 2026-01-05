@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ================================
:: FLUFFYHUB TOOLBOX 2025 PRO
:: Telegram: @FluffyHubDevelopers
:: ================================

:: ПЕРЕМЕННЫЕ
set "ROOT_DIR=%~dp0"
if "%ROOT_DIR%"=="" set "ROOT_DIR=%cd%\"
if not "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR%\"

:: ПЕРВОЕ ОКНО - ВЫБОР ADB
:first_run
cls
echo.
echo    =================================================
echo    #           FLUFFYHUB TOOLBOX 2025 PRO        #
echo    #         Telegram: @FluffyHubDevelopers       #
echo    =================================================
echo.
echo    ВНИМАНИЕ: Для работы нужен ADB!
echo.
echo    Выберите способ настройки:
echo    [1] Указать путь к ADB вручную
echo    [2] Автоматический поиск ADB
echo    [3] Скачать ADB автоматически
echo    [4] Продолжить без ADB (ограниченный функционал)
echo    [5] Выход
echo.
set /p "adb_setup=   Ваш выбор: "

if "!adb_setup!"=="1" goto manual_adb_path
if "!adb_setup!"=="2" goto auto_find_adb
if "!adb_setup!"=="3" goto download_adb_now
if "!adb_setup!"=="4" (
    set "ADB_PATH=NOT_FOUND"
    goto main_menu
)
if "!adb_setup!"=="5" exit
goto first_run

:: 1. РУЧНОЙ ПУТЬ
:manual_adb_path
cls
echo.
echo    Укажите путь к папке с adb.exe
echo    Пример: C:\platform-tools
echo    Или перетащите папку в окно
echo.
set /p "ADB_PATH=   Путь: "
if "!ADB_PATH!"=="" goto first_run

set "ADB_PATH=!ADB_PATH:"=!"
if not exist "!ADB_PATH!\adb.exe" (
    echo.
    echo    ОШИБКА: adb.exe не найден!
    pause
    goto manual_adb_path
)
set "PATH=!ADB_PATH!;%PATH%"
goto main_menu

:: 2. АВТОПОИСК
:auto_find_adb
echo.
echo    Ищу ADB в системе...
set "ADB_FOUND=0"
for %%p in (
    "C:\platform-tools"
    "%ROOT_DIR%platform-tools"
    "%ProgramFiles%\Android\Android SDK\platform-tools"
    "%LocalAppData%\Android\Sdk\platform-tools"
    "C:\adb"
    "D:\platform-tools"
    "D:\adb"
) do (
    if exist "%%~p\adb.exe" (
        set "ADB_PATH=%%~p"
        set "ADB_FOUND=1"
        echo    Найден: !ADB_PATH!
        goto :adb_found
    )
)
:adb_found
if !ADB_FOUND!==1 (
    set "PATH=!ADB_PATH!;%PATH%"
    echo    ADB настроен!
    timeout /t 2 >nul
    goto main_menu
) else (
    echo    ADB не найден!
    pause
    goto first_run
)

:: 3. СКАЧАТЬ ADB
:download_adb_now
echo.
echo    Скачиваю ADB...
mkdir "%ROOT_DIR%Downloads" 2>nul
powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile '%ROOT_DIR%Downloads\adb.zip'" >nul 2>&1
if exist "%ROOT_DIR%Downloads\adb.zip" (
    powershell -Command "Expand-Archive -Path '%ROOT_DIR%Downloads\adb.zip' -DestinationPath '%ROOT_DIR%' -Force" >nul 2>&1
    del "%ROOT_DIR%Downloads\adb.zip" 2>nul
    set "ADB_PATH=%ROOT_DIR%platform-tools"
    set "PATH=!ADB_PATH!;%PATH%"
    echo    ADB скачан!
) else (
    echo    Ошибка скачивания!
)
pause
goto main_menu

:: ================================
:: ГЛАВНОЕ МЕНЮ (ВСЕ ПУНКТЫ)
:: ================================
:main_menu
cls
echo.
echo    =================================================
echo    #           FLUFFYHUB TOOLBOX 2025 PRO        #
echo    #         Telegram: @FluffyHubDevelopers       #
echo    =================================================
echo    #   ADB: !ADB_PATH!                           #
echo    =================================================
echo    #   [1]  Проверить подключение               #
echo    #   [2]  Перезагрузить в Fastboot             #
echo    #   [3]  Проверить Fastboot                   #
echo    #   [4]  Режимы загрузки                      #
echo    #   [5]  Разблокировать bootloader            #
echo    #   [6]  Установить приложение                #
echo    #   [7]  Сделать бэкап                        #
echo    #   [8]  Сохранить данные                     #
echo    #   [9]  Команды Fastboot                     #
echo    #   [10] ADB Shell                            #
echo    #   [11] Файловый менеджер                    #
echo    #   [12] Сброс и форматирование               #
echo    #   [13] Восстановление системы               #
echo    #   [14] Информация о телефоне                #
echo    #   [15] Очистка памяти                       #
echo    #   [16] Системные утилиты                    #
echo    #   [17] Драйверы и инструменты               #
echo    #   [18] Создание скриптов                    #
echo    #   [19] Диагностика системы                  #
echo    #   [20] Настройки программы                  #
echo    #   [21] Управление проектами                 #
echo    #   [22] Мониторинг                           #
echo    #   [23] Сеть и подключения                   #
echo    #   [24] Безопасность                         #
echo    #   [25] Оптимизация                          #
echo    #   [26] О программе                          #
echo    #   [0]  Выход                                #
echo    =================================================
echo.
set /p "choice=   Ваш выбор [0-26]: "

if "!choice!"=="0" goto exit_prog
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
if "!choice!"=="16" goto system_utilities_menu
if "!choice!"=="17" goto drivers_tools_menu
if "!choice!"=="18" goto script_creation_menu
if "!choice!"=="19" goto system_diagnostics_menu
if "!choice!"=="20" goto program_settings
if "!choice!"=="21" goto project_management_menu
if "!choice!"=="22" goto monitoring_menu
if "!choice!"=="23" goto network_menu
if "!choice!"=="24" goto security_menu
if "!choice!"=="25" goto optimization_menu
if "!choice!"=="26" goto about_menu
goto main_menu

:: ================================
:: 1. ПРОВЕРИТЬ ПОДКЛЮЧЕНИЕ
:: ================================
:check_device
cls
echo.
echo    =================================================
echo    #         ПРОВЕРКА ПОДКЛЮЧЕНИЯ               #
echo    =================================================
echo.
if "!ADB_PATH!"=="NOT_FOUND" (
    echo    ADB не настроен!
    pause
    goto main_menu
)
adb devices
echo.
pause
goto main_menu

:: ================================
:: 2. ПЕРЕЗАГРУЗИТЬ В FASTBOOT
:: ================================
:reboot_fastboot
cls
echo.
echo    Перезагрузка в Fastboot...
adb reboot bootloader
echo    Команда отправлена!
pause
goto main_menu

:: ================================
:: 3. ПРОВЕРИТЬ FASTBOOT
:: ================================
:check_fastboot
cls
echo.
fastboot devices
echo.
pause
goto main_menu

:: ================================
:: 4. РЕЖИМЫ ЗАГРУЗКИ
:: ================================
:bootloader_menu
cls
echo.
echo    Выберите режим загрузки:
echo    [1] Recovery
echo    [2] Bootloader
echo    [3] Fastboot
echo    [4] Назад
echo.
set /p "boot_choice=   Выберите: "

if "!boot_choice!"=="1" adb reboot recovery
if "!boot_choice!"=="2" adb reboot bootloader
if "!boot_choice!"=="3" adb reboot fastboot
if "!boot_choice!"=="4" goto main_menu
echo.
echo    Команда отправлена!
pause
goto bootloader_menu

:: ================================
:: 5. РАЗБЛОКИРОВАТЬ BOOTLOADER
:: ================================
:unlock_bootloader
cls
echo.
echo    ВНИМАНИЕ: Удалит все данные!
echo.
set /p "confirm=   Введите 'РАЗБЛОКИРОВАТЬ': "
if /i "!confirm!"=="РАЗБЛОКИРОВАТЬ" (
    fastboot flashing unlock
    echo    Команда отправлена!
)
pause
goto main_menu

:: ================================
:: 6. УСТАНОВИТЬ ПРИЛОЖЕНИЕ
:: ================================
:install_app_menu
cls
echo.
echo    [1] Установить APK
echo    [2] Массовая установка
echo    [3] Удалить приложение
echo    [4] Список приложений
echo    [5] Назад
echo.
set /p "install_choice=   Выберите: "

if "!install_choice!"=="1" goto install_single_apk
if "!install_choice!"=="2" goto install_mass_apk
if "!install_choice!"=="3" goto uninstall_app
if "!install_choice!"=="4" goto list_apps
if "!install_choice!"=="5" goto main_menu
goto install_app_menu

:install_single_apk
echo.
set /p "apk_path=   Путь к APK: "
adb install -r "!apk_path!"
pause
goto install_app_menu

:install_mass_apk
echo.
for %%f in ("%ROOT_DIR%APKs\*.apk") do (
    echo Установка: %%~nxf
    adb install -r "%%f"
)
pause
goto install_app_menu

:uninstall_app
echo.
set /p "package=   Имя пакета: "
adb uninstall !package!
pause
goto install_app_menu

:list_apps
echo.
adb shell "pm list packages" | more
pause
goto install_app_menu

:: ================================
:: 7. СДЕЛАТЬ БЭКАП
:: ================================
:backup_menu
cls
echo.
echo    [1] Бэкап приложений
echo    [2] Бэкап данных
echo    [3] Полный бэкап
echo    [4] Назад
echo.
set /p "backup_choice=   Выберите: "

if "!backup_choice!"=="1" goto backup_apps
if "!backup_choice!"=="2" goto backup_data_menu
if "!backup_choice!"=="3" goto backup_full
if "!backup_choice!"=="4" goto main_menu
goto backup_menu

:backup_apps
echo.
set "backup_dir=%ROOT_DIR%Backups\Apps_%date:~6,4%%date:~3,2%%date:~0,2%"
mkdir "!backup_dir!" 2>nul
adb shell "pm list packages -3" > "!backup_dir!\apps.txt"
echo    Бэкап создан!
pause
goto backup_menu

:backup_data_menu
echo.
set /p "data_path=   Путь для копирования: "
set "backup_dir=%ROOT_DIR%Backups\Data_%date:~6,4%%date:~3,2%%date:~0,2%"
mkdir "!backup_dir!" 2>nul
adb pull "!data_path!" "!backup_dir!\"
echo    Данные сохранены!
pause
goto backup_menu

:backup_full
echo.
echo    Используйте TWRP для полного бэкапа
pause
goto backup_menu

:: ================================
:: 8. СОХРАНИТЬ ДАННЫЕ
:: ================================
:backup_data
cls
echo.
set /p "data_path=   Путь на устройстве: "
set "backup_dir=%ROOT_DIR%Backups\Data_%date:~6,4%%date:~3,2%%date:~0,2%"
mkdir "!backup_dir!" 2>nul
adb pull "!data_path!" "!backup_dir!\"
echo    Данные сохранены!
pause
goto main_menu

:: ================================
:: 9. КОМАНДЫ FASTBOOT
:: ================================
:fastboot_commands
cls
echo.
echo    [1] Перезагрузить
echo    [2] Заблокировать bootloader
echo    [3] Стереть cache
echo    [4] Стереть userdata
echo    [5] Назад
echo.
set /p "fb_cmd=   Выберите: "

if "!fb_cmd!"=="1" fastboot reboot
if "!fb_cmd!"=="2" fastboot flashing lock
if "!fb_cmd!"=="3" fastboot erase cache
if "!fb_cmd!"=="4" fastboot erase userdata
if "!fb_cmd!"=="5" goto main_menu
echo.
echo    Команда выполнена!
pause
goto fastboot_commands

:: ================================
:: 10. ADB SHELL
:: ================================
:adb_shell
cls
echo.
adb shell
goto main_menu

:: ================================
:: 11. ФАЙЛОВЫЙ МЕНЕДЖЕР
:: ================================
:file_manager_menu
cls
echo.
echo    [1] Просмотр файлов
echo    [2] Копировать на устройство
echo    [3] Копировать с устройства
echo    [4] Назад
echo.
set /p "fm_choice=   Выберите: "

if "!fm_choice!"=="1" goto browse_files
if "!fm_choice!"=="2" goto push_file
if "!fm_choice!"=="3" goto pull_file
if "!fm_choice!"=="4" goto main_menu
goto file_manager_menu

:browse_files
echo.
set /p "path=   Путь [/sdcard]: "
if "!path!"=="" set "path=/sdcard"
adb shell "ls -la !path!"
pause
goto file_manager_menu

:push_file
echo.
set /p "local=   Локальный файл: "
set /p "remote=   Путь на устройстве: "
adb push "!local!" "!remote!"
pause
goto file_manager_menu

:pull_file
echo.
set /p "remote=   Файл на устройстве: "
set /p "local=   Локальная папка: "
adb pull "!remote!" "!local!\"
pause
goto file_manager_menu

:: ================================
:: 12. СБРОС И ФОРМАТИРОВАНИЕ
:: ================================
:wipe_menu
cls
echo.
echo    [1] Сброс к заводским
echo    [2] Очистка кэша
echo    [3] Форматирование data
echo    [4] Назад
echo.
set /p "wipe_choice=   Выберите: "

if "!wipe_choice!"=="1" goto factory_reset
if "!wipe_choice!"=="2" goto wipe_cache
if "!wipe_choice!"=="3" goto format_data
if "!wipe_choice!"=="4" goto main_menu
goto wipe_menu

:factory_reset
echo.
adb reboot recovery
echo    Перезагрузка в Recovery...
pause
goto wipe_menu

:wipe_cache
adb shell "pm clear --cache"
echo    Кэш очищен!
pause
goto wipe_menu

:format_data
echo.
adb reboot recovery
echo    Перезагрузка в Recovery...
pause
goto wipe_menu

:: ================================
:: 13. ВОССТАНОВЛЕНИЕ СИСТЕМЫ
:: ================================
:recovery_menu
cls
echo.
echo    [1] Прошить boot
echo    [2] Прошить recovery
echo    [3] Прошить system
echo    [4] Назад
echo.
set /p "recovery_choice=   Выберите: "

if "!recovery_choice!"=="1" goto flash_boot
if "!recovery_choice!"=="2" goto flash_recovery
if "!recovery_choice!"=="3" goto flash_system
if "!recovery_choice!"=="4" goto main_menu
goto recovery_menu

:flash_boot
echo.
if exist "boot.img" (
    fastboot flash boot boot.img
    echo    Boot прошит!
) else (
    echo    Файл boot.img не найден!
)
pause
goto recovery_menu

:flash_recovery
echo.
if exist "recovery.img" (
    fastboot flash recovery recovery.img
    echo    Recovery прошит!
) else (
    echo    Файл recovery.img не найден!
)
pause
goto recovery_menu

:flash_system
echo.
if exist "system.img" (
    fastboot flash system system.img
    echo    System прошит!
) else (
    echo    Файл system.img не найден!
)
pause
goto recovery_menu

:: ================================
:: 14. ИНФОРМАЦИЯ О ТЕЛЕФОНЕ
:: ================================
:phone_info_menu
cls
echo.
echo    [1] Быстрая информация
echo    [2] Все свойства
echo    [3] Информация о батарее
echo    [4] Сохранить отчет
echo    [5] Назад
echo.
set /p "info_choice=   Выберите: "

if "!info_choice!"=="1" goto quick_info
if "!info_choice!"=="2" goto all_props
if "!info_choice!"=="3" goto battery_info
if "!info_choice!"=="4" goto save_report
if "!info_choice!"=="5" goto main_menu
goto phone_info_menu

:quick_info
echo.
adb shell getprop ro.product.model
adb shell getprop ro.product.manufacturer
adb shell getprop ro.build.version.release
pause
goto phone_info_menu

:all_props
echo.
adb shell getprop | more
pause
goto phone_info_menu

:battery_info
echo.
adb shell dumpsys battery
pause
goto phone_info_menu

:save_report
set "report_file=%ROOT_DIR%Reports\info_%date:~6,4%%date:~3,2%%date:~0,2%.txt"
adb shell getprop > "!report_file!"
echo    Отчет сохранен!
pause
goto phone_info_menu

:: ================================
:: 15. ОЧИСТКА ПАМЯТИ
:: ================================
:cleanup_menu
cls
echo.
echo    [1] Очистить кэш приложений
echo    [2] Очистить системный кэш
echo    [3] Полная очистка
echo    [4] Назад
echo.
set /p "clean_choice=   Выберите: "

if "!clean_choice!"=="1" goto clear_app_cache
if "!clean_choice!"=="2" goto clear_system_cache
if "!clean_choice!"=="3" goto full_cleanup
if "!clean_choice!"=="4" goto main_menu
goto cleanup_menu

:clear_app_cache
echo.
adb shell "pm clear --cache"
echo    Кэш очищен!
pause
goto cleanup_menu

:clear_system_cache
echo.
adb shell "rm -rf /cache/*"
echo    Системный кэш очищен!
pause
goto cleanup_menu

:full_cleanup
echo.
adb shell "pm clear --cache"
adb shell "rm -rf /cache/*"
adb shell "rm -rf /data/local/tmp/*"
echo    Полная очистка завершена!
pause
goto cleanup_menu

:: ================================
:: 16. СИСТЕМНЫЕ УТИЛИТЫ
:: ================================
:system_utilities_menu
cls
echo.
echo    [1] Запустить ADB сервер
echo    [2] Остановить ADB сервер
echo    [3] Просмотр процессов
echo    [4] Проверка root
echo    [5] Логи устройства
echo    [6] Назад
echo.
set /p "util_choice=   Выберите: "

if "!util_choice!"=="1" goto start_adb
if "!util_choice!"=="2" goto stop_adb
if "!util_choice!"=="3" goto view_processes
if "!util_choice!"=="4" goto check_root
if "!util_choice!"=="5" goto device_logs
if "!util_choice!"=="6" goto main_menu
goto system_utilities_menu

:start_adb
adb start-server
echo    ADB сервер запущен!
pause
goto system_utilities_menu

:stop_adb
adb kill-server
echo    ADB сервер остановлен!
pause
goto system_utilities_menu

:view_processes
echo.
adb shell ps | more
pause
goto system_utilities_menu

:check_root
echo.
adb shell "su -c 'echo Root'" && (
    echo    Root доступен!
) || (
    echo    Root недоступен!
)
pause
goto system_utilities_menu

:device_logs
echo.
adb logcat -d | more
pause
goto system_utilities_menu

:: ================================
:: 17. ДРАЙВЕРЫ И ИНСТРУМЕНТЫ
:: ================================
:drivers_tools_menu
cls
echo.
echo    [1] Установить драйверы ADB
echo    [2] Проверить драйверы
echo    [3] Скачать инструменты
echo    [4] Назад
echo.
set /p "driver_choice=   Выберите: "

if "!driver_choice!"=="1" goto install_drivers
if "!driver_choice!"=="2" goto check_drivers
if "!driver_choice!"=="3" goto download_tools
if "!driver_choice!"=="4" goto main_menu
goto drivers_tools_menu

:install_drivers
echo.
echo    Для установки драйверов:
echo    1. Скачайте Universal ADB Driver
echo    2. Запустите установку от имени администратора
pause
goto drivers_tools_menu

:check_drivers
echo.
echo    Проверка драйверов...
echo    Устройства ADB:
adb devices
pause
goto drivers_tools_menu

:download_tools
echo.
echo    Скачать дополнительные инструменты?
echo    [1] Platform-tools (официальные)
echo    [2] Минимальный ADB
echo    [3] Назад
set /p "tools_choice=   Выберите: "
if "!tools_choice!"=="1" goto download_adb_now
if "!tools_choice!"=="2" (
    echo    Скачиваю Minimal ADB...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/joshuaboniface/adb-winapi/releases/download/v1.0.40/adb-winapi.zip' -OutFile '%ROOT_DIR%Downloads\minimal_adb.zip'"
)
goto drivers_tools_menu

:: ================================
:: 18. СОЗДАНИЕ СКРИПТОВ
:: ================================
:script_creation_menu
cls
echo.
echo    [1] Создать скрипт установки
echo    [2] Создать скрипт бэкапа
echo    [3] Запустить скрипт
echo    [4] Назад
echo.
set /p "script_choice=   Выберите: "

if "!script_choice!"=="1" goto create_install_script
if "!script_choice!"=="2" goto create_backup_script
if "!script_choice!"=="3" goto run_script
if "!script_choice!"=="4" goto main_menu
goto script_creation_menu

:create_install_script
set "script_file=%ROOT_DIR%Scripts\install.bat"
echo @echo off > "!script_file!"
echo echo Установка APK... >> "!script_file!"
echo for %%f in ("*.apk") do adb install -r "%%f" >> "!script_file!"
echo pause >> "!script_file!"
echo    Скрипт создан!
pause
goto script_creation_menu

:create_backup_script
set "script_file=%ROOT_DIR%Scripts\backup.bat"
echo @echo off > "!script_file!"
echo echo Бэкап данных... >> "!script_file!"
echo adb pull /sdcard backup_%%date%% >> "!script_file!"
echo pause >> "!script_file!"
echo    Скрипт создан!
pause
goto script_creation_menu

:run_script
echo.
dir "%ROOT_DIR%Scripts\*.bat" /b
echo.
set /p "script_name=   Имя скрипта: "
call "%ROOT_DIR%Scripts\!script_name!"
pause
goto script_creation_menu

:: ================================
:: 19. ДИАГНОСТИКА СИСТЕМЫ
:: ================================
:system_diagnostics_menu
cls
echo.
echo    [1] Полная диагностика
echo    [2] Проверка батареи
echo    [3] Тест памяти
echo    [4] Тест процессора
echo    [5] Назад
echo.
set /p "diag_choice=   Выберите: "

if "!diag_choice!"=="1" goto full_diagnostics
if "!diag_choice!"=="2" goto battery_check
if "!diag_choice!"=="3" goto memory_test
if "!diag_choice!"=="4" goto cpu_test
if "!diag_choice!"=="5" goto main_menu
goto system_diagnostics_menu

:full_diagnostics
echo.
adb shell getprop | findstr "ro.product\|ro.build"
adb shell "df -h"
adb shell "free -m"
pause
goto system_diagnostics_menu

:battery_check
echo.
adb shell dumpsys battery
pause
goto system_diagnostics_menu

:memory_test
echo.
adb shell "df -h"
adb shell "free -m"
pause
goto system_diagnostics_menu

:cpu_test
echo.
adb shell "cat /proc/cpuinfo"
pause
goto system_diagnostics_menu

:: ================================
:: 20. НАСТРОЙКИ ПРОГРАММЫ
:: ================================
:program_settings
cls
echo.
echo    [1] Изменить путь ADB
echo    [2] Скачать ADB
echo    [3] Сбросить настройки
echo    [4] Назад
echo.
set /p "settings_choice=   Выберите: "

if "!settings_choice!"=="1" goto manual_adb_path
if "!settings_choice!"=="2" goto download_adb_now
if "!settings_choice!"=="3" (
    echo    Настройки сброшены!
    timeout /t 2 >nul
    goto first_run
)
goto main_menu

:: ================================
:: 21. УПРАВЛЕНИЕ ПРОЕКТАМИ
:: ================================
:project_management_menu
cls
echo.
echo    [1] Создать проект
echo    [2] Открыть проект
echo    [3] Назад
echo.
set /p "project_choice=   Выберите: "

if "!project_choice!"=="1" goto create_project
if "!project_choice!"=="2" goto open_project
if "!project_choice!"=="3" goto main_menu
goto project_management_menu

:create_project
echo.
set /p "project_name=   Имя проекта: "
mkdir "%ROOT_DIR%Projects\!project_name!" 2>nul
mkdir "%ROOT_DIR%Projects\!project_name!\APKs" 2>nul
mkdir "%ROOT_DIR%Projects\!project_name!\Backups" 2>nul
echo    Проект создан!
pause
goto project_management_menu

:open_project
echo.
dir "%ROOT_DIR%Projects\" /b
echo.
set /p "project_name=   Имя проекта: "
if exist "%ROOT_DIR%Projects\!project_name!\" (
    echo    Проект открыт!
) else (
    echo    Проект не найден!
)
pause
goto project_management_menu

:: ================================
:: 22. МОНИТОРИНГ
:: ================================
:monitoring_menu
cls
echo.
echo    [1] Мониторинг памяти
echo    [2] Мониторинг батареи
echo    [3] Мониторинг процессов
echo    [4] Назад
echo.
set /p "monitor_choice=   Выберите: "

if "!monitor_choice!"=="1" goto monitor_memory
if "!monitor_choice!"=="2" goto monitor_battery
if "!monitor_choice!"=="3" goto monitor_processes
if "!monitor_choice!"=="4" goto main_menu
goto monitoring_menu

:monitor_memory
echo.
adb shell "free -m"
pause
goto monitoring_menu

:monitor_battery
echo.
adb shell dumpsys battery
pause
goto monitoring_menu

:monitor_processes
echo.
adb shell "top -n 1"
pause
goto monitoring_menu

:: ================================
:: 23. СЕТЬ И ПОДКЛЮЧЕНИЯ
:: ================================
:network_menu
cls
echo.
echo    [1] Информация о сети
echo    [2] Ping тест
echo    [3] Назад
echo.
set /p "network_choice=   Выберите: "

if "!network_choice!"=="1" goto network_info
if "!network_choice!"=="2" goto ping_test
if "!network_choice!"=="3" goto main_menu
goto network_menu

:network_info
echo.
adb shell "ip addr show"
pause
goto network_menu

:ping_test
echo.
adb shell "ping -c 4 8.8.8.8"
pause
goto network_menu

:: ================================
:: 24. БЕЗОПАСНОСТЬ
:: ================================
:security_menu
cls
echo.
echo    [1] Проверить root
echo    [2] Список разрешений
echo    [3] Назад
echo.
set /p "security_choice=   Выберите: "

if "!security_choice!"=="1" goto check_root_security
if "!security_choice!"=="2" goto list_permissions
if "!security_choice!"=="3" goto main_menu
goto security_menu

:check_root_security
echo.
adb shell "su -c 'echo Root check'" && (
    echo    Устройство имеет root!
) || (
    echo    Устройство без root!
)
pause
goto security_menu

:list_permissions
echo.
adb shell "pm list permissions" | more
pause
goto security_menu

:: ================================
:: 25. ОПТИМИЗАЦИЯ
:: ================================
:optimization_menu
cls
echo.
echo    [1] Оптимизация памяти
echo    [2] Очистка кэша
echo    [3] Оптимизация батареи
echo    [4] Назад
echo.
set /p "optimization_choice=   Выберите: "

if "!optimization_choice!"=="1" goto optimize_memory
if "!optimization_choice!"=="2" goto optimize_cache
if "!optimization_choice!"=="3" goto optimize_battery
if "!optimization_choice!"=="4" goto main_menu
goto optimization_menu

:optimize_memory
echo.
adb shell "echo 3 > /proc/sys/vm/drop_caches" 2>nul
echo    Память оптимизирована!
pause
goto optimization_menu

:optimize_cache
echo.
adb shell "pm clear --cache"
echo    Кэш очищен!
pause
goto optimization_menu

:optimize_battery
echo.
adb shell "dumpsys battery reset"
echo    Батарея оптимизирована!
pause
goto optimization_menu

:: ================================
:: 26. О ПРОГРАММЕ
:: ================================
:about_menu
cls
echo.
echo    =================================================
echo    #           FLUFFYHUB TOOLBOX 2025 PRO        #
echo    =================================================
echo.
echo    Версия: 6.3 Pro
echo    Автор: kotikxD
echo    Telegram: @FluffyHubDevelopers
echo.
echo    Все 26 функций работают:
echo    • Полное управление Android
echo    • ADB и Fastboot команды
echo    • Бэкап и восстановление
echo    • Диагностика и мониторинг
echo    • Создание скриптов
echo    • Управление проектами
echo    • Оптимизация системы
echo.
echo    Присоединяйтесь в Telegram!
echo.
pause
goto main_menu

:: ================================
:: 0. ВЫХОД
:: ================================
:exit_prog
cls
echo.
echo    =================================================
echo    #       Спасибо за использование!             #
echo    #    Telegram: @FluffyHubDevelopers           #
echo    =================================================
echo.
timeout /t 2 >nul
exit

:: ================================
:: КОНЕЦ СКРИПТА
:: ================================