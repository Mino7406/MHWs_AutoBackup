@echo off
:: 인코딩을 UTF-8로 설정
chcp 65001 >NUL

:: ID 변수 설정
set UserID="여기에 스팀 ID 입력"

:: 경로 변수 설정
set BackupFolder="여기에 저장할 파일 경로 입력"

:: 스팀 기본 경로 설정
set SteamInstallDir=C:\Program Files (x86)\Steam

:: 게임이 실행 중인지 검색. 없다면 LAUNCH로 이동, 실행 중이라면 SKIP라벨로 이동
TASKLIST | FINDSTR /I /C:"MonsterHunterWilds.exe" >NUL || GOTO LAUNCH
GOTO SKIP
:LAUNCH
start "" "MonsterHunterWilds.exe"
:SKIP

:: 저장 파일에 연-월-일-시-분-초 형식으로 백업 파일 생성
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>NUL`) do set "DateTime=%%I"

:: 만약 Powershell 오류 시 윈도우 시스템 관리에서 불러오기
if not defined DateTime (
    for /f "usebackq tokens=2 delims==" %%T in (`wmic os get LocalDateTime /value 2^>NUL`) do if not defined DateTime set "DateTimeRaw=%%T"
    if defined DateTimeRaw (
        set "DateTime=%DateTimeRaw:~0,4%-%DateTimeRaw:~4,2%-%DateTimeRaw:~6,2%_%DateTimeRaw:~8,2%-%DateTimeRaw:~10,2%-%DateTimeRaw:~12%"
        set "DateTimeRaw="
    )
)

:: 모든 방법 실패 시 임의의 숫자 기입
if not defined DateTime set "DateTime=backup_%RANDOM%"

:: 최상위 백업 폴더를 생성 (이미 존재 할 경우 발생하는 에러는 2>NUL로 숨김 처리)
md "%BackupFolder%" 2>NUL
:: 최상위 폴더 안에 하위 폴더 생성
md "%BackupFolder%\%DateTime%"

:: 스팀 클라우드 세이브에서 파일을 복사
robocopy "%SteamInstallDir%\userdata\%UserID%\2246340\remote" "%BackupFolder%\%DateTime%" /E /COPY:DAT /R:1 /W:1 >NUL

