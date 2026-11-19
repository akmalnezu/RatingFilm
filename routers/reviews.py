from typing import Optional
from fastapi import APIRouter, Query
from database import get_db_cursor
from schemas import ReviewCreateRequest

router = APIRouter(prefix="/api/reviews", tags=["Reviews & Ratings (Procedure & View)"])

@router.get("", summary="Daftar Ulasan & Rating (View: ViewDetailReview)")
def get_reviews(
    film_id: Optional[int] = Query(None, description="Filter ulasan berdasarkan ID film"),
    user_id: Optional[int] = Query(None, description="Filter ulasan berdasarkan ID user")
):
    """
    Mengambil data dari View `ViewDetailReview`.
    """
    with get_db_cursor() as cursor:
        query = "SELECT * FROM ViewDetailReview WHERE 1=1"
        params = []

        if film_id is not None:
            query += " AND film_id = %s"
            params.append(film_id)
        if user_id is not None:
            query += " AND user_id = %s"
            params.append(user_id)

        query += " ORDER BY tanggal_review DESC"
        cursor.execute(query, tuple(params))
        rows = cursor.fetchall()

        return {
            "source": "View ViewDetailReview",
            "total": len(rows),
            "data": rows
        }

@router.post("", summary="Beri / Update Ulasan & Rating (Procedure: BeriUlasan)")
def submit_review(req: ReviewCreateRequest):
    """
    Memanggil Stored Procedure `BeriUlasan(p_user_id, p_film_id, p_nilai, p_isi_review)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("BeriUlasan", [req.user_id, req.film_id, req.nilai, req.isi_review])
        return {
            "source": "Procedure BeriUlasan",
            "success": True,
            "message": "Ulasan dan rating berhasil diproses via procedure BeriUlasan!"
        }

@router.delete("", summary="Hapus Ulasan & Rating (Procedure: HapusUlasan)")
def delete_review(user_id: int = Query(...), film_id: int = Query(...)):
    """
    Memanggil Stored Procedure `HapusUlasan(p_user_id, p_film_id)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("HapusUlasan", [user_id, film_id])
        return {
            "source": "Procedure HapusUlasan",
            "success": True,
            "message": "Ulasan dan rating berhasil dihapus via procedure HapusUlasan!"
        }
