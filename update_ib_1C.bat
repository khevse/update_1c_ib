%echo off
rem code page = OEM
Setlocal EnableDelayedExpansion

SET "SOURCE_IB=%1"
SET "PLATFORM=%2"
SET "PATH_TO_UPDATES=%3"
SET "CONF_NAME=%4"
SET "VERSIONS=%5"
SET "USER_NAME="�����������""
SET "USER_PWD=<TODO>"

IF "%USER_NAME%" == "<TODO>" (
    SET /P "USER_NAME=User name of information base:"
)
IF "%USER_PWD%" == "<TODO>" (
    SET /P "USER_PWD=User password of information base:"
)

rem �������� ����祪 � ��砫� � ���� ���祭��
SET "SOURCE_IB=%SOURCE_IB:~1,-1%"
SET "VERSIONS=%VERSIONS:~1,-1%"
SET "USER_NAME=%USER_NAME:~1,-1%"
SET "PATH_TO_UPDATES=%PATH_TO_UPDATES:~1,-1%"

rem ����塞 �஡���
SET "VERSIONS=%VERSIONS: =%"

echo Source ib="%SOURCE_IB%" (example: "C:\1C.dt")
echo Version platform=%PLATFORM% (example: 8.3.6.2299)
echo Path to the updates="%PATH_TO_UPDATES%" (example: "C:\Users\UserName\AppData\Roaming\1C\1cv8\tmplts\1c")
echo Configuration name=%CONF_NAME% (example: trade or accounting)
echo Versions of updates="%VERSIONS%" (example: "3_0_33_18, 3_0_33_30", The maximum number of elements=26)
echo User name="%USER_NAME%" (example: "Khramtsov E.S.")

if "%SOURCE_IB%" == "~1,-1" (
    exit 1
)
if "%PLATFORM%" == "" (
    exit 1
)
if "%CONF_NAME%" == "" (
    exit 1
)
if "%VERSIONS%" == "~1,-1" (
    exit 1
)
if "%PATH_TO_UPDATES%" == "~1,-1" (
    exit 1
)

SET "CURRENT_DIR=%CD%"
rem �����ଠ � ������� ���ன �㤥� �믮����� ����������
SET "PLATFORM=C:\Program Files (x86)\1cv8\%PLATFORM%\bin\1cv8.exe"

rem ��⠫�� ���஬ �㤥� �믮����� ���� ����������
SET "PATH_TO_UPDATE_DIR=%PATH_TO_UPDATES%\%CONF_NAME%"


rem ----------------------------------------------------------------------------------
echo ������� ���ଠ樮���� ����, � ���ன �㤥� �믮����� ����������
rem ----------------------------------------------------------------------------------
rem ���� � �६������ ��⠫��� ����� ������塞
SET "PATH_TO_IB=%CURRENT_DIR%\ib"
rem ��� ���� ����� ����� ���祭�� F ��� S
SET "BASE_TYPE=F"

"%PLATFORM%" CREATEINFOBASE File="%PATH_TO_IB%" 
"%PLATFORM%" DESIGNER /%BASE_TYPE%"%PATH_TO_IB%" /RestoreIB "%SOURCE_IB%" /Out "RestoreIB_��室���_���ଠ樮����_����.log"
if not %ERRORLEVEL% == 0 (
    echo �訡�� ᮧ����� ��室��� ��䮬�樮���� ����. ����� ���. ��� �訡��:%ERRORLEVEL%
    exit
)
rem ----------------------------------------------------------------------------------

FOR /L %%i IN (1,1,26) DO (

    for /F "usebackq tokens=1-26 delims=, " %%A IN (`echo !VERSIONS!,`) do (
        SET "CURRENT_VERSION=%%A"
        SET "VERSIONS=%%B,%%C,%%D,%%E,%%F,%%G,%%H,%%I,%%J,%%K,%%L,%%M,%%N,%%O,%%P,%%Q,%%R,%%S,%%T,%%U,%%V,%%W,%%X,%%Y,%%Z"
        IF "!VERSIONS!!CURRENT_VERSION!" == "" (
            goto end
        )
        
        echo __________________________________________________________________
        for /F "usebackq tokens=1,2,3,4 delims=_" %%A IN (`echo !CURRENT_VERSION!`) do SET "SHOW_VERSION_TEXT=%%A.%%B.%%C.%%D"
        echo ���������� ���ଠ樮���� ���� �� �����: !SHOW_VERSION_TEXT!
        echo __________________________________________________________________

        for /F "usebackq tokens=1,2,3,4,5,6,7 delims=.:, " %%A IN (`echo !date!.!time!`) do SET "DATE_TIME=__%%C_%%B_%%A___%%D_%%E_%%F"

        rem ������� ��⠫�� � ����� �㤥� ᪫��뢠�� ��� �� ��ᠥ��� ���������� ���ଠ樮���� ����
        SET "LOG_DIR_NAME=!DATE_TIME!_!CONF_NAME!_!CURRENT_VERSION!"
        SET "PATH_TO_LOG_DIR=!CURRENT_DIR!\!DATE_TIME!__v_!CURRENT_VERSION!"

        mkdir "!PATH_TO_LOG_DIR!"

        echo !time! Step 1-4. Create backup before update
        "%PLATFORM%" DESIGNER /%BASE_TYPE%"%PATH_TO_IB%" /N"%USER_NAME%" /P"%USER_PWD%" /DumpIB "!PATH_TO_LOG_DIR!\before_v_!CURRENT_VERSION!.dt" /Out "!PATH_TO_LOG_DIR!\_1_DumpIB_before_update.log"
        if not !ERRORLEVEL! == 0 (
            echo Error code: !ERRORLEVEL!
            exit 1
        )

        echo !time! Step 2-4. Update information base
        "%PLATFORM%" DESIGNER /%BASE_TYPE%"%PATH_TO_IB%" /N"%USER_NAME%" /P"%USER_PWD%" /UpdateCfg "!PATH_TO_UPDATE_DIR!\!CURRENT_VERSION!\1cv8.cfu" /Out "!PATH_TO_LOG_DIR!\_2_UpdateCfg.log"
        if not !ERRORLEVEL! == 0 (
            echo Error code: !ERRORLEVEL!
            exit 1
        )

        echo !time! Step 3-4. Update configuration file
        "%PLATFORM%" DESIGNER /%BASE_TYPE%"%PATH_TO_IB%" /N"%USER_NAME%" /P"%USER_PWD%" /UpdateDBCfg /Out "!PATH_TO_LOG_DIR!\_3_UpdateDBCfg.log"
        if not !ERRORLEVEL! == 0 (
            echo Error code: !ERRORLEVEL!
            exit 1
        )

        echo !time! Step 4-4. Open to confirm the configuration update
        "%PLATFORM%" ENTERPRISE /%BASE_TYPE%"%PATH_TO_IB%" /N"%USER_NAME%" /P"%USER_PWD%"

    )
)

:end

echo �reating the result file
"%PLATFORM%" DESIGNER /%BASE_TYPE%"%PATH_TO_IB%" /N"%USER_NAME%" /P"%USER_PWD%" /DumpIB "%CURRENT_DIR%\result_v_!CURRENT_VERSION!.dt" /Out "%CURRENT_DIR%\DumpIB_result.log"


echo Success