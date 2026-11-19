# 펫비포 서버 (FastAPI + MariaDB)

앱은 MariaDB에 직접 붙지 않습니다. Flutter → 이 API → MariaDB 입니다.

## 1. MariaDB

Windows면 [MariaDB](https://mariadb.org/download/) 또는 XAMPP의 MySQL/MariaDB를 켭니다. 기본 포트는 `3306`입니다. 이 프로젝트 PC에는 MariaDB 13.0 서비스가 이미 있습니다.

`server/.env.example`을 `server/.env`로 복사하고 **설치할 때 정한 root 비밀번호**를 넣습니다.

Windows 설치본이 `auth_gssapi_client`만 허용하면 Python(`pymysql`)이 root로 못 붙습니다. 그때는 HeidiSQL/maria 클라이언트로 아래를 한 번 실행하고 `.env`의 사용자를 `petbefore`로 바꿉니다.

```sql
CREATE DATABASE IF NOT EXISTS petbefore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'petbefore'@'localhost' IDENTIFIED BY '여기에비밀번호';
GRANT ALL PRIVILEGES ON petbefore.* TO 'petbefore'@'localhost';
ALTER USER 'petbefore'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('여기에비밀번호');
FLUSH PRIVILEGES;
```

## 2. 실행

```text
cd server
python -m pip install -r requirements.txt
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

브라우저에서 `http://127.0.0.1:8000/health` 가 `ok`이면 DB까지 붙은 것입니다.

테스트 계정은 서버가 자동으로 만듭니다.

- 이메일: `test@petbefore.kr`
- 비밀번호: `test1234`

## 3. 앱에서 주소 맞추기

```text
flutter run --dart-define=PETBEFORE_API_BASE=http://127.0.0.1:8000
```

안드로이드 에뮬레이터는 `http://10.0.2.2:8000`, 실제 폰은 같은 Wi-Fi의 PC 주소(`http://192.168.x.x:8000`)를 씁니다. 서버를 끄고 싶으면 `PETBEFORE_API_BASE=off` 입니다. 서버가 꺼져 있으면 가입·로그인은 이 기기 저장으로 넘어갑니다.
