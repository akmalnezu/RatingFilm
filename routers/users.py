from fastapi import APIRouter, HTTPException
from database import get_db_cursor

router = APIRouter(prefix="/api/users", tags=["Users & Admin (Procedure & View)"])

@router.get("/activity", summary="Lihat Semua Aktivitas Pengguna (View: AktivitasUser)")
def get_all_users_activity():
    """
    Mengambil data seluruh user dari View `AktivitasUser`.
    """
    with get_db_cursor() as cursor:
        cursor.execute("SELECT * FROM AktivitasUser")
        rows = cursor.fetchall()
        return {
            "source": "View AktivitasUser",
            "total": len(rows),
            "data": rows
        }

@router.get("/{user_id}/activity", summary="Ringkasan Aktivitas User Tertentu (View: AktivitasUser)")
def get_user_activity(user_id: int):
    """
    Mengambil ringkasan aktivitas spesifik user dari View `AktivitasUser`.
    """
    with get_db_cursor() as cursor:
        cursor.execute("SELECT * FROM AktivitasUser WHERE user_id = %s", (user_id,))
        rows = cursor.fetchall()
        if not rows:
            raise HTTPException(status_code=404, detail="Aktivitas user tidak ditemukan!")

        return {
            "source": "View AktivitasUser",
            "data": rows[0]
        }

@router.delete("/{user_id}", summary="Hapus Akun User (Procedure: HapusAkun)")
def delete_user_account(user_id: int):
    """
    Memanggil Stored Procedure `HapusAkun(p_user_id)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("HapusAkun", [user_id])
        return {
            "source": "Procedure HapusAkun",
            "success": True,
            "message": "Akun user berhasil dihapus via procedure HapusAkun!"
        }

@router.delete("/admin/{admin_id}", summary="Hapus Akun Admin (Procedure: HapusAKunAdmin)")
def delete_admin_account(admin_id: int):
    """
    Memanggil Stored Procedure `HapusAKunAdmin(p_admin_id)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("HapusAKunAdmin", [admin_id])
        return {
            "source": "Procedure HapusAKunAdmin",
            "success": True,
            "message": "Akun admin berhasil dihapus via procedure HapusAKunAdmin!"
        }
