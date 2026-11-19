import os
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import get_db_cursor
from routers import auth, films, reviews, watchlist, users

app = FastAPI(
    title="MBD Film Database API (FastAPI)",
    description="REST API backend yang memanggil Stored Procedures (02_Procedure.sql) dan Views (04_View.sql) di database MySQL ratingfilm.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Daftarkan Router
app.include_router(auth.router)
app.include_router(films.router)
app.include_router(reviews.router)
app.include_router(watchlist.router)
app.include_router(users.router)

@app.get("/", tags=["General"], summary="Ringkasan API (Procedures & Views)")
def root():
    return {
        "name": "MBD Film Database API (FastAPI)",
        "version": "1.0.0",
        "description": "API terintegrasi langsung dengan Stored Procedure dan View MySQL.",
        "docs": "/docs",
        "redoc": "/redoc",
        "endpoints": {
            "auth": [
                "POST /api/auth/register (Procedure: RegistrasiUser)",
                "POST /api/auth/login (Procedure: LoginUser)",
                "POST /api/auth/admin/login (Procedure: LoginAdmin)"
            ],
            "films": [
                "GET /api/films (View: FilmLengkapDenganGenre)",
                "GET /api/films?genre={genre} (Procedure: FilterFilmByGenre)",
                "GET /api/films/popular (View: ViewFilmPopuler)",
                "GET /api/films/summary-ratings (View: FilmWithAverageRating)",
                "GET /api/films/{id} (View: FilmLengkapDenganGenre & ViewDetailReview)",
                "POST /api/films (Procedure: TambahFilm)",
                "PUT /api/films/{id} (Procedure: UbahFilm)",
                "DELETE /api/films/{id} (Procedure: HapusFilm)",
                "POST /api/films/{id}/genres (Procedure: TambahGenreKeFilm)"
            ],
            "reviews": [
                "GET /api/reviews (View: ViewDetailReview)",
                "POST /api/reviews (Procedure: BeriUlasan)",
                "DELETE /api/reviews?user_id={id}&film_id={id} (Procedure: HapusUlasan)"
            ],
            "watchlist": [
                "GET /api/watchlist/{user_id} (View: DaftarWatchlistUser)",
                "POST /api/watchlist (Procedure: TambahWatchlist)",
                "DELETE /api/watchlist?user_id={id}&film_id={id} (Procedure: HapusWatchlist)"
            ],
            "users": [
                "GET /api/users/activity (View: AktivitasUser)",
                "GET /api/users/{user_id}/activity (View: AktivitasUser)",
                "DELETE /api/users/{id} (Procedure: HapusAkun)",
                "DELETE /api/users/admin/{id} (Procedure: HapusAKunAdmin)"
            ]
        }
    }

@app.get("/health", tags=["General"], summary="Cek Status Koneksi Database")
def health_check():
    try:
        with get_db_cursor() as cursor:
            cursor.execute("SELECT 1 + 1 AS health")
            row = cursor.fetchone()
            return {"status": "ok", "db": "connected", "result": row["health"]}
    except Exception as e:
        return {"status": "error", "db": "disconnected", "error": str(e)}

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
