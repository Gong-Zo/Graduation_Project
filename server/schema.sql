-- 펫비포 MariaDB 스키마. FastAPI가 기동 때 없으면 같은 구조로 만든다.
CREATE DATABASE IF NOT EXISTS petbefore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE petbefore;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  public_id VARCHAR(64) NOT NULL UNIQUE,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS survey_records (
  id VARCHAR(64) PRIMARY KEY,
  user_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL,
  payload JSON NOT NULL,
  CONSTRAINT fk_survey_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS member_libraries (
  user_id BIGINT PRIMARY KEY,
  payload JSON NOT NULL,
  updated_at DATETIME NOT NULL,
  CONSTRAINT fk_library_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
