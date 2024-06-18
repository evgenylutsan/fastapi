from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.openapi.docs import get_swagger_ui_oauth2_redirect_html
from starlette.middleware.base import BaseHTTPMiddleware
import uvicorn
from app.router import event, user, speaker, sponsor, calendar
from app.db import models
from app.db.database import engine
from app.auth import authentication
from starlette.requests import Request
from starlette.responses import Response
import base64
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI(
    docs_url="/api/docs", 
    openapi_url="/api/openapi.json"  # 
    )

security = HTTPBasic()

def get_current_username(credentials: HTTPBasicCredentials = Depends(security)):
    correct_username = "admin"
    correct_password = "admin123"
    if credentials.username != correct_username or credentials.password != correct_password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

class BasicAuthMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, username: str, password: str):
        super().__init__(app)
        self.username = username
        self.password = password

    async def dispatch(self, request: Request, call_next):
        if request.url.path in ["api/docs", "api/redoc", "api/openapi.json"]:
            auth = request.headers.get("Authorization")
            if auth is None:
                return Response(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    headers={"WWW-Authenticate": "Basic"},
                )
            try:
                scheme, credentials = auth.split()
                if scheme.lower() != "basic":
                    raise ValueError("Invalid scheme")
                decoded = base64.b64decode(credentials).decode("ascii")
                username, password = decoded.split(":", 1)
                if username != self.username or password != self.password:
                    raise ValueError("Invalid credentials")
            except Exception as e:
                return Response(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    headers={"WWW-Authenticate": "Basic"},
                )
        response = await call_next(request)
        return response

app.add_middleware(BasicAuthMiddleware, username="admin", password="admin123")

app.include_router(authentication.router)
app.include_router(event.router)
app.include_router(user.router)
app.include_router(speaker.router)
app.include_router(sponsor.router)
app.include_router(calendar.router)

origins = [
    "http://127.0.0.1:5500"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

models.Base.metadata.create_all(engine)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

@app.get("/api/swagger-redirect", include_in_schema=False)
async def swagger_redirect():
    return get_swagger_ui_oauth2_redirect_html()