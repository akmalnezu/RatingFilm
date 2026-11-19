import os
from pathlib import Path
from contextlib import contextmanager
from fastapi import HTTPException
import mysql.connector
from mysql.connector import pooling

# Helper mandiri untuk membaca file .env tanpa perlu dependensi pihak ketiga
def load_env_file():
    env_path = Path(__file__).resolve().parent / ".env"
    if env_path.exists():
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    key = key.strip()
                    val = val.strip().strip("'\"")
                    os.environ[key] = val

load_env_file()

# Lazy initialization connection pool
_pool = None

def get_pool():
    global _pool
    if _pool is None:
        load_env_file()
        db_config = {
            "host": os.getenv("DB_HOST", "localhost"),
            "user": os.getenv("DB_USER", "user_film"),
            "password": os.getenv("DB_PASSWORD", "password123"),
            "database": os.getenv("DB_NAME", "ratingfilm"),
            "port": int(os.getenv("DB_PORT", "3306")),
            "pool_name": "ratingfilm_pool",
            "pool_size": 10,
            "autocommit": True
        }
        try:
            _pool = pooling.MySQLConnectionPool(**db_config)
        except mysql.connector.Error as err:
            raise HTTPException(
                status_code=500,
                detail=f"Koneksi database gagal diinisialisasi: {err.msg}"
            )
    return _pool

@contextmanager
def get_db_cursor():
    """
    Context manager untuk koneksi dan cursor database.
    Otomatis menangkap MySQL SIGNAL SQLSTATE '45000' dari Stored Procedure.
    """
    pool = get_pool()
    conn = None
    cursor = None
    try:
        conn = pool.get_connection()
        cursor = conn.cursor(dictionary=True)
        yield cursor
    except mysql.connector.Error as err:
        # SQLSTATE 45000 adalah sinyal validasi dari Stored Procedure
        if getattr(err, "sqlstate", None) == "45000":
            raise HTTPException(status_code=400, detail=err.msg)
        # Duplicate entry
        if getattr(err, "errno", None) == 1062:
            raise HTTPException(status_code=409, detail=f"Data duplikat terdeteksi: {err.msg}")
        raise HTTPException(status_code=500, detail=f"Database error: {err.msg}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
