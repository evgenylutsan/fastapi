from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.openapi.docs import get_swagger_ui_html, get_redoc_html
import uvicorn
from app.router import event, user, speaker, sponsor, calendar
from app.db import models
from app.db.database import engine
from app.auth import authentication

app = FastAPI()

security = HTTPBasic()

def get_current_username(credentials: HTTPBasicCredentials = Depends(security)):
    correct_username = "admin"
    correct_password = "admin"
    if credentials.username != correct_username or credentials.password != correct_password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

@app.get("/docs", include_in_schema=False)
async def get_docs(username: str = Depends(get_current_username)):
    return get_swagger_ui_html(openapi_url=app.openapi_url, title="docs")

@app.get("/redoc", include_in_schema=False)
async def get_redoc(username: str = Depends(get_current_username)):
    return get_redoc_html(openapi_url=app.openapi_url, title="redoc")

app.include_router(authentication.router)
app.include_router(event.router)
app.include_router(user.router)
app.include_router(speaker.router)
app.include_router(sponsor.router)
app.include_router(calendar.router)

models.Base.metadata.create_all(engine)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

