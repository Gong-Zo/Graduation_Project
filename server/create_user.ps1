# MariaDB root로 접속해 앱용 petbefore 사용자를 만든다.
$mariadb = 'C:\Program Files\MariaDB 13.0\bin\mariadb.exe'
$sql = Join-Path $PSScriptRoot 'create_petbefore_user.sql'
$envFile = Join-Path $PSScriptRoot '.env'

if (-not (Test-Path $mariadb)) {
    Write-Error "mariadb.exe 를 찾지 못했습니다: $mariadb"
    exit 1
}

Write-Host 'MariaDB를 설치할 때 정한 root 비밀번호를 입력하세요. 화면에는 안 보입니다.'
$secure = Read-Host -AsSecureString 'root 비밀번호'
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $rootPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}

$args = @('-u', 'root', '--protocol=tcp', '-h', '127.0.0.1')
if ($rootPassword.Length -gt 0) {
    $args += "-p$rootPassword"
}

Get-Content -Raw $sql | & $mariadb @args
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host '접속에 실패했습니다. root 비밀번호가 맞는지 다시 확인하세요.'
    exit $LASTEXITCODE
}

@"
MARIADB_HOST=127.0.0.1
MARIADB_PORT=3306
MARIADB_USER=petbefore
MARIADB_PASSWORD=petbefore1234
MARIADB_DATABASE=petbefore
JWT_SECRET=petbefore-dev-change-me
"@ | Set-Content -Path $envFile -Encoding utf8

Write-Host ''
Write-Host 'petbefore 사용자를 만들었습니다. server/.env 도 채워 두었습니다.'
Write-Host '이제 서버를 켜면 됩니다: py -3 -m uvicorn main:app --host 0.0.0.0 --port 8000'
