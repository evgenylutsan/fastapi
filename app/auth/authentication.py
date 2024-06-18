from fastapi import APIRouter, Depends, HTTPException, status, Response
from fastapi.security.oauth2 import OAuth2PasswordRequestForm
from jose import JWTError, jwt
from sqlalchemy.orm.session import Session
from app.db.database import get_db
from app.db import models, db_user
from app.db.hash import Hash
from app.auth import oauth2
from app.schemas import User, UserDisplay, UserAuth

router = APIRouter(
    tags=['authentication']    
)

# Авторизация пользователя
@router.post(
        '/api/login',
        summary= 'Авторизация пользователя'
        )
async def get_token(response: Response, request: UserAuth,db: Session = Depends(get_db)):
    user = db.query(models.DbUser).filter(models.DbUser.email == request.email_login).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Неверно введена почта")
    if not Hash.verify(user.password, request.password_login):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Неверно введен пароль")
    
    access_token = oauth2.create_access_token(data={'sub': user.email})
    response.set_cookie('event_access_token', access_token, httponly=True)
    
    return {
        'access_token': access_token,
        'username': user.name,
        'email': user.email
    }
    
# Регистрация пользователя
@router.post(
    '/api/registration', 
    response_model=UserDisplay,
    summary= 'Регистрация пользователя'
    )
def create_user(request: User, db: Session = Depends(get_db)):
    existing_user = db_user.existing_user(db, request.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail='Данная почта уже используется'
        )
    return db_user.create_user(db, request)
    
@router.get('/api/session')
async def get_session(token: str = Depends(oauth2.oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, oauth2.SECRET_KEY, algorithms=[oauth2.ALGORITHM])
        name: str = payload.get('sub')
        if name is None:
          raise credentials_exception
    except JWTError:
      raise credentials_exception
    return {'user': name}

    