from fastapi import APIRouter, status
from database import get_db_cursor
from schemas import UserRegisterRequest, UserLoginRequest, AdminLoginRequest

router = APIRouter(prefix="/api/auth", tags=["Auth (Procedures)"])

@router.post("/register", status_code=status.HTTP_201_CREATED, summary="Registrasi User Baru (Procedure: RegistrasiUser)")
def register_user(req: UserRegisterRequest):
    """
    Memanggil Stored Procedure `RegistrasiUser(p_username, p_email, p_password)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("RegistrasiUser", [req.username, req.email, req.password])
        return {
            "success": True,
            "message": "Registrasi user berhasil via procedure RegistrasiUser!"
        }

@router.post("/login", status_code=status.HTTP_200_OK, summary="Login User (Procedure: LoginUser)")
def login_user(req: UserLoginRequest):
    """
    Memanggil Stored Procedure `LoginUser(p_akun, p_password)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("LoginUser", [req.akun, req.password])
        user_data = None
        for result in cursor.stored_results():
            rows = result.fetchall()
            if rows:
                user_data = rows[0]
                break

        return {
            "success": True,
            "message": "Login user berhasil via procedure LoginUser!",
            "data": user_data
        }

@router.post("/admin/login", status_code=status.HTTP_200_OK, summary="Login Admin (Procedure: LoginAdmin)")
def login_admin(req: AdminLoginRequest):
    """
    Memanggil Stored Procedure `LoginAdmin(p_username, p_password)`.
    """
    with get_db_cursor() as cursor:
        cursor.callproc("LoginAdmin", [req.username, req.password])
        admin_data = None
        for result in cursor.stored_results():
            rows = result.fetchall()
            if rows:
                admin_data = rows[0]
                break

        return {
            "success": True,
            "message": "Login admin berhasil via procedure LoginAdmin!",
            "data": admin_data
        }
