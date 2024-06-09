from fastapi import FastAPI
import uvicorn
from app.router import event, user, speaker, sponsor, calendar
from app.db import models
from app.db.database import engine
from app.auth import authentication

app = FastAPI()
app.include_router(authentication.router)
app.include_router(event.router)
app.include_router(user.router)
app.include_router(speaker.router)
app.include_router(sponsor.router)
app.include_router(calendar.router)

models.Base.metadata.create_all(engine)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

