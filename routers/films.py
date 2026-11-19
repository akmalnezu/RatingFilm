from typing import Optional
from fastapi import APIRouter, HTTPException, Query, status
from database import get_db_cursor
from schemas import FilmCreateRequest, FilmUpdateRequest, FilmGenreRequest

router = APIRouter(prefix="/api/films", tags=["Films (Procedure & View)"])

@router.get("", summary="Daftar Film (View: FilmLengkapDenganGenre / Procedure: FilterFilmByGenre)")
def get_films(genre: Optional[str] = Query(None, description="Filter genre via Stored Procedure FilterFilmByGenre")):
    """
    Jika parameter `genre` diberikan, memanggil Stored Procedure `FilterFilmByGenre(p_genre)`.
    Jika tanpa parameter, mengambil dari View `FilmLengkapDenganGenre`.
    """
    with get_db_cursor() as cursor:
        if genre:
            cursor.callproc("FilterFilmByGenre", [genre])
            films = []
            for result in cursor.stored_results():
                films = result.fetchall()
                break
            return {
                "source": "Procedure FilterFilmByGenre",
                "filter": {"genre": genre},
                "total": len(films),
                "data": films
            }

        cursor.execute("SELECT * FROM FilmLengkapDenganGenre ORDER BY average_rating DESC")
        rows = cursor.fetchall()
        return {
            "source": "View FilmLengkapDenganGenre",
            "total": len(rows),
            "data": rows
        }

@router.get("/popular", summary="10 Film Terpopuler (View: ViewFilmPopuler)")
def get_popular_films():
    """
    Mengambil data dari View `ViewFilmPopuler`.
    """
    with get_db_cursor() as cursor:
        cursor.execute("SELECT * FROM ViewFilmPopuler ORDER BY rating_rata_rata DESC, jumlah_pemberi_rating DESC LIMIT 10")
        rows = cursor.fetchall()
        return {
            "source": "View ViewFilmPopuler",
            "total": len(rows),
            "data": rows
        }

@router.get("/summary-ratings", summary="Ringkasan Rating Film (View: FilmWithAverageRating)")
def get_films_with_average_rating():
    """
    Mengambil data dari View `FilmWithAverageRating`.
    """
    with get_db_cursor() as cursor:
        cursor.execute("SELECT * FROM FilmWithAverageRating ORDER BY average_rating DESC")
        rows = cursor.fetchall()
        return {
            "source": "View FilmWithAverageRating",
            "total": len(rows),
            "data": rows
        }

@router.get("/{film_id}", summary="Detail Film & Ulasan (View: FilmLengkapDenganGenre & ViewDetailReview)")
def get_film_detail(film_id: int):
    """
    Mengambil detail film dari View `FilmLengkapDenganGenre` dan ulasan dari View `ViewDetailReview`.
    """
    with get_db_cursor() as cursor:
        cursor.execute("SELECT * FROM FilmLengkapDenganGenre WHERE film_id = %s", (film_id,))
        film_rows = cursor.fetchall()
        if not film_rows:
            raise HTTPException(status_code=404, detail="Film tidak ditemukan!")

        cursor.execute(
            "SELECT user_id, nama_user, rating_diberikan, isi_review, tanggal_review FROM ViewDetailReview WHERE film_id = %s ORDER BY tanggal_review DESC",
            (film_id,)
        )
        reviews = cursor.fetchall()

        data = dict(film_rows[0])
        data["reviews"] = reviews
        return {
            "source": "View FilmLengkapDenganGenre & ViewDetailReview",
            "data": data
        }

@router.post("", status_code=status.HTTP_201_CREATED, summary="Tambah Film Baru (Procedure: TambahFilm)")
def create_film(req: FilmCreateRequest):
    """
    Memanggil Stored Procedure `TambahFilm(...)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc(
            "TambahFilm",
            [req.admin_id, req.judul, req.sutradara, req.pemeran, req.tahun_rilis, req.sinopsis]
        )
        return {
            "source": "Procedure TambahFilm",
            "success": True,
            "message": "Film berhasil ditambahkan via procedure TambahFilm!"
        }

@router.put("/{film_id}", summary="Ubah Data Film (Procedure: UbahFilm)")
def update_film(film_id: int, req: FilmUpdateRequest):
    """
    Memanggil Stored Procedure `UbahFilm(...)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc(
            "UbahFilm",
            [film_id, req.judul, req.sutradara, req.pemeran, req.tahun_rilis, req.sinopsis]
        )
        return {
            "source": "Procedure UbahFilm",
            "success": True,
            "message": "Data film berhasil diubah via procedure UbahFilm!"
        }

@router.delete("/{film_id}", summary="Hapus Film (Procedure: HapusFilm)")
def delete_film(film_id: int):
    """
    Memanggil Stored Procedure `HapusFilm(...)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("HapusFilm", [film_id])
        return {
            "source": "Procedure HapusFilm",
            "success": True,
            "message": "Film berhasil dihapus via procedure HapusFilm!"
        }

@router.post("/{film_id}/genres", summary="Tambah Genre ke Film (Procedure: TambahGenreKeFilm)")
def add_genre_to_film(film_id: int, req: FilmGenreRequest):
    """
    Memanggil Stored Procedure `TambahGenreKeFilm(p_film_id, p_nama_genre)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("TambahGenreKeFilm", [film_id, req.nama_genre])
        return {
            "source": "Procedure TambahGenreKeFilm",
            "success": True,
            "message": f"Genre '{req.nama_genre}' berhasil ditambahkan ke film ID {film_id}!"
        }
