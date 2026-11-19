from fastapi import APIRouter, Query, status
from database import get_db_cursor
from schemas import WatchlistRequest

router = APIRouter(prefix="/api/watchlist", tags=["Watchlist (Procedure & View)"])

@router.get("/{user_id}", summary="Lihat Daftar Watchlist User (View: DaftarWatchlistUser)")
def get_user_watchlist(user_id: int):
    """
    Mengambil data dari View `DaftarWatchlistUser`.
    """
    with get_db_cursor() as cursor:
        cursor.execute(
            "SELECT film_id, judul_film, tanggal_ditambahkan FROM DaftarWatchlistUser WHERE user_id = %s ORDER BY tanggal_ditambahkan DESC",
            (user_id,)
        )
        rows = cursor.fetchall()
        return {
            "source": "View DaftarWatchlistUser",
            "user_id": user_id,
            "total": len(rows),
            "data": rows
        }

@router.post("", status_code=status.HTTP_201_CREATED, summary="Tambah Film ke Watchlist (Procedure: TambahWatchlist)")
def add_to_watchlist(req: WatchlistRequest):
    """
    Memanggil Stored Procedure `TambahWatchlist(p_user_id, p_film_id)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("TambahWatchlist", [req.user_id, req.film_id])
        return {
            "source": "Procedure TambahWatchlist",
            "success": True,
            "message": "Film berhasil ditambahkan ke watchlist via procedure TambahWatchlist!"
        }

@router.delete("", summary="Hapus Film dari Watchlist (Procedure: HapusWatchlist)")
def remove_from_watchlist(user_id: int = Query(...), film_id: int = Query(...)):
    """
    Memanggil Stored Procedure `HapusWatchlist(p_user_id, p_film_id)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("HapusWatchlist", [user_id, film_id])
        return {
            "source": "Procedure HapusWatchlist",
            "success": True,
            "message": "Film berhasil dihapus dari watchlist via procedure HapusWatchlist!"
        }
