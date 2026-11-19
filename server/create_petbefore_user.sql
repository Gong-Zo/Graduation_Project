-- root로 한 번만 실행. 앱은 petbefore 사용자로만 붙는다.
CREATE DATABASE IF NOT EXISTS petbefore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'petbefore'@'localhost' IDENTIFIED BY 'petbefore1234';
CREATE USER IF NOT EXISTS 'petbefore'@'127.0.0.1' IDENTIFIED BY 'petbefore1234';

GRANT ALL PRIVILEGES ON petbefore.* TO 'petbefore'@'localhost';
GRANT ALL PRIVILEGES ON petbefore.* TO 'petbefore'@'127.0.0.1';

-- pymysql이 Windows GSSAPI를 못 쓰므로 native 비밀번호로 바꾼다.
ALTER USER 'petbefore'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('petbefore1234');
ALTER USER 'petbefore'@'127.0.0.1' IDENTIFIED VIA mysql_native_password USING PASSWORD('petbefore1234');

FLUSH PRIVILEGES;
