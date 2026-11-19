"""펫비포 FastAPI. Flutter는 여기만 호출하고 MariaDB 비밀번호는 앱에 넣지 않는다."""

from __future__ import annotations

import json
import os
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any

import bcrypt
import jwt
import pymysql
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field
from pymysql.cursors import DictCursor

load_dotenv()

MARIADB_HOST = os.getenv("MARIADB_HOST", "127.0.0.1")
MARIADB_PORT = int(os.getenv("MARIADB_PORT", "3306"))
MARIADB_USER = os.getenv("MARIADB_USER", "root")
MARIADB_PASSWORD = os.getenv("MARIADB_PASSWORD", "")
MARIADB_DATABASE = os.getenv("MARIADB_DATABASE", "petbefore")
JWT_SECRET = os.getenv("JWT_SECRET", "petbefore-dev-change-me")
JWT_ALG = "HS256"
TEST_EMAIL = "test@petbefore.kr"
TEST_PASSWORD = "test1234"
TEST_PUBLIC_ID = "u_test_account"


def _connect(*, database: str | None = MARIADB_DATABASE):
    return pymysql.connect(
        host=MARIADB_HOST,
        port=MARIADB_PORT,
        user=MARIADB_USER,
        password=MARIADB_PASSWORD,
        database=database,
        charset="utf8mb4",
        autocommit=True,
        cursorclass=DictCursor,
    )


def _ensure_schema() -> None:
    """DB·테이블이 없으면 만든다. 앱 계정에 CREATE DATABASE 권한이 없어도 기존 DB는 쓴다."""
    try:
        conn = _connect(database=None)
        try:
            with conn.cursor() as cur:
                cur.execute(
                    "CREATE DATABASE IF NOT EXISTS "
                    f"`{MARIADB_DATABASE}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
                )
        finally:
            conn.close()
    except pymysql.Error:
        pass

    conn = _connect()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS users (
                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                  public_id VARCHAR(64) NOT NULL UNIQUE,
                  email VARCHAR(190) NOT NULL UNIQUE,
                  password_hash VARCHAR(255) NOT NULL,
                  created_at DATETIME NOT NULL
                )
                """
            )
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS survey_records (
                  id VARCHAR(64) PRIMARY KEY,
                  user_id BIGINT NOT NULL,
                  created_at DATETIME NOT NULL,
                  payload JSON NOT NULL,
                  CONSTRAINT fk_survey_user FOREIGN KEY (user_id)
                    REFERENCES users(id) ON DELETE CASCADE
                )
                """
            )
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS member_libraries (
                  user_id BIGINT PRIMARY KEY,
                  payload JSON NOT NULL,
                  updated_at DATETIME NOT NULL,
                  CONSTRAINT fk_library_user FOREIGN KEY (user_id)
                    REFERENCES users(id) ON DELETE CASCADE
                )
                """
            )
    finally:
        conn.close()


def get_db():
    conn = _connect()
    try:
        yield conn
    finally:
        conn.close()


class RegisterBody(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    email: str
    password: str
    confirm_password: str | None = Field(default=None, alias="confirmPassword")


class LoginBody(BaseModel):
    email: str
    password: str


class SurveyBody(BaseModel):
    record: dict[str, Any]


class LibraryBody(BaseModel):
    library: dict[str, Any]


def _normalize_email(email: str) -> str:
    return email.strip().lower()


def _validate_email(email: str) -> None:
    if "@" not in email or "." not in email.split("@")[-1]:
        raise HTTPException(status_code=400, detail="이메일 형식이 아닙니다.")


def _validate_password(password: str) -> None:
    if len(password) < 8:
        raise HTTPException(status_code=400, detail="비밀번호는 8자 이상이어야 합니다.")


def _hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def _check_password(password: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode("utf-8"), hashed.encode("utf-8"))
    except ValueError:
        return False


def _token_for(user: dict[str, Any]) -> str:
    payload = {
        "sub": user["public_id"],
        "uid": user["id"],
        "exp": datetime.now(timezone.utc) + timedelta(days=30),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALG)


def _user_json(user: dict[str, Any]) -> dict[str, Any]:
    created = user["created_at"]
    if isinstance(created, datetime) and created.tzinfo is None:
        created = created.replace(tzinfo=timezone.utc)
    return {
        "id": user["public_id"],
        "email": user["email"],
        "createdAt": created.isoformat() if isinstance(created, datetime) else str(created),
    }


def _auth_json(user: dict[str, Any]) -> dict[str, Any]:
    return {"token": _token_for(user), "user": _user_json(user)}


def current_user(
    authorization: str | None = Header(default=None),
    db=Depends(get_db),
) -> dict[str, Any]:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="로그인이 필요합니다.")
    token = authorization.split(" ", 1)[1].strip()
    try:
        data = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG])
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="세션이 만료되었거나 올바르지 않습니다.")
    with db.cursor() as cur:
        cur.execute("SELECT * FROM users WHERE public_id = %s", (data.get("sub"),))
        user = cur.fetchone()
    if user is None:
        raise HTTPException(status_code=401, detail="계정을 찾지 못했습니다.")
    return user


def _seed_test_account() -> None:
    conn = _connect()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT id FROM users WHERE email = %s", (TEST_EMAIL,))
            if cur.fetchone() is not None:
                return
            cur.execute(
                """
                INSERT INTO users (public_id, email, password_hash, created_at)
                VALUES (%s, %s, %s, %s)
                """,
                (TEST_PUBLIC_ID, TEST_EMAIL, _hash_password(TEST_PASSWORD), datetime(2026, 1, 1)),
            )
    finally:
        conn.close()


_ensure_schema()
_seed_test_account()

app = FastAPI(title="펫비포 API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    conn = _connect()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
    finally:
        conn.close()
    return {"status": "ok", "database": MARIADB_DATABASE}


@app.post("/auth/register")
def register(body: RegisterBody, db=Depends(get_db)) -> dict[str, Any]:
    email = _normalize_email(body.email)
    _validate_email(email)
    _validate_password(body.password)
    confirm = body.confirm_password
    if confirm is not None and confirm != body.password:
        raise HTTPException(status_code=400, detail="비밀번호가 일치하지 않습니다.")
    with db.cursor() as cur:
        cur.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cur.fetchone() is not None:
            raise HTTPException(status_code=409, detail="이미 가입된 이메일입니다.")
        cur.execute(
            """
            INSERT INTO users (public_id, email, password_hash, created_at)
            VALUES (%s, %s, %s, %s)
            """,
            (f"u_{uuid.uuid4().hex}", email, _hash_password(body.password), datetime.utcnow()),
        )
        cur.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cur.fetchone()
    return _auth_json(user)


@app.post("/auth/login")
def login(body: LoginBody, db=Depends(get_db)) -> dict[str, Any]:
    email = _normalize_email(body.email)
    with db.cursor() as cur:
        cur.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cur.fetchone()
    if user is None or not _check_password(body.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 올바르지 않습니다.")
    return _auth_json(user)


@app.get("/auth/me")
def me(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    return {"user": _user_json(user)}


@app.get("/surveys")
def list_surveys(
    user: dict[str, Any] = Depends(current_user),
    db=Depends(get_db),
) -> dict[str, Any]:
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT payload FROM survey_records
            WHERE user_id = %s
            ORDER BY created_at DESC
            """,
            (user["id"],),
        )
        rows = cur.fetchall()
    records = []
    for row in rows:
        payload = row["payload"]
        records.append(json.loads(payload) if isinstance(payload, str) else payload)
    return {"records": records}


@app.post("/surveys")
def save_survey(
    body: SurveyBody,
    user: dict[str, Any] = Depends(current_user),
    db=Depends(get_db),
) -> dict[str, Any]:
    record = dict(body.record)
    record_id = str(record.get("id") or f"r_{uuid.uuid4().hex}")
    record["id"] = record_id
    record["userId"] = user["public_id"]
    created_raw = record.get("createdAt")
    try:
        created_at = (
            datetime.fromisoformat(str(created_raw).replace("Z", "+00:00")).replace(tzinfo=None)
            if created_raw
            else datetime.utcnow()
        )
    except ValueError:
        created_at = datetime.utcnow()
    payload = json.dumps(record, ensure_ascii=False)
    with db.cursor() as cur:
        cur.execute("SELECT id FROM survey_records WHERE id = %s", (record_id,))
        if cur.fetchone() is None:
            cur.execute(
                """
                INSERT INTO survey_records (id, user_id, created_at, payload)
                VALUES (%s, %s, %s, %s)
                """,
                (record_id, user["id"], created_at, payload),
            )
        else:
            cur.execute(
                """
                UPDATE survey_records
                SET payload = %s, created_at = %s, user_id = %s
                WHERE id = %s
                """,
                (payload, created_at, user["id"], record_id),
            )
    return {"record": record}


@app.get("/library")
def get_library(
    user: dict[str, Any] = Depends(current_user),
    db=Depends(get_db),
) -> dict[str, Any]:
    with db.cursor() as cur:
        cur.execute("SELECT payload FROM member_libraries WHERE user_id = %s", (user["id"],))
        row = cur.fetchone()
    if row is None:
        return {"library": {}}
    payload = row["payload"]
    return {"library": json.loads(payload) if isinstance(payload, str) else payload}


@app.put("/library")
def put_library(
    body: LibraryBody,
    user: dict[str, Any] = Depends(current_user),
    db=Depends(get_db),
) -> dict[str, Any]:
    payload = json.dumps(body.library, ensure_ascii=False)
    now = datetime.utcnow()
    with db.cursor() as cur:
        cur.execute(
            """
            INSERT INTO member_libraries (user_id, payload, updated_at)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE payload = VALUES(payload), updated_at = VALUES(updated_at)
            """,
            (user["id"], payload, now),
        )
    return {"library": body.library}


@app.get("/")
def root() -> dict[str, str]:
    return {"name": "petbefore", "docs": "/docs"}
