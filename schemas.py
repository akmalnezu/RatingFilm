from typing import Optional, List, Union
from pydantic import BaseModel, Field

class UserRegisterRequest(BaseModel):
    username: str = Field(..., min_length=2, max_length=50, example="Wisnu")
    email: str = Field(..., max_length=100, example="wisnu@example.com")
    password: str = Field(..., min_length=4, max_length=100, example="password123")

class UserLoginRequest(BaseModel):
    akun: str = Field(..., description="Username atau Email", example="wisnu@example.com")
    password: str = Field(..., example="password123")

class AdminLoginRequest(BaseModel):
    username: str = Field(..., example="admin1")
    password: str = Field(..., example="admin1123")

class FilmCreateRequest(BaseModel):
    admin_id: int = Field(..., example=1)
    judul: str = Field(..., max_length=100, example="Inception")
    sutradara: str = Field(..., max_length=100, example="Christopher Nolan")
    pemeran: str = Field(..., max_length=100, example="Leonardo DiCaprio")
    tahun_rilis: int = Field(..., example=2010)
    sinopsis: str = Field(..., max_length=100, example="A thief who steals corporate secrets through dream-sharing.")
    genres: Optional[Union[List[str], str]] = Field(None, example=["Action", "Sci-Fi"])

class FilmUpdateRequest(BaseModel):
    judul: str = Field(..., max_length=100, example="Inception (Remastered)")
    sutradara: str = Field(..., max_length=100, example="Christopher Nolan")
    pemeran: str = Field(..., max_length=100, example="Leonardo DiCaprio, Joseph Gordon-Levitt")
    tahun_rilis: int = Field(..., example=2010)
    sinopsis: str = Field(..., max_length=100, example="Dom Cobb is a skilled thief who enters dreams.")

class FilmGenreRequest(BaseModel):
    nama_genre: str = Field(..., max_length=50, example="Action")

class ReviewCreateRequest(BaseModel):
    user_id: int = Field(..., example=1)
    film_id: int = Field(..., example=1)
    nilai: int = Field(..., ge=1, le=10, description="Rating dari 1 hingga 10", example=9)
    isi_review: str = Field(..., max_length=250, example="Film yang sangat luar biasa dan berkesan!")

class WatchlistRequest(BaseModel):
    user_id: int = Field(..., example=1)
    film_id: int = Field(..., example=1)
