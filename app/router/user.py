from typing import List
from fastapi import APIRouter, Depends, status, HTTPException
from app.schemas import UserBase, UserDisplay, User
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db import db_user


router = APIRouter(
    prefix='/user',
    tags=['user']
)

# Прочитать всех пользователей
@router.get(
    '/', 
    response_model=List[UserDisplay],
    summary= 'Список всех пользователей'
    )
def get_all_users(db: Session = Depends(get_db)):
    return db_user.get_all_users(db)


# Прочитать одного пользователя
@router.get(
    '/findbyemail/{id}', 
    response_model=UserDisplay, 
    summary= 'Поиск пользователя по почте', 
    response_description='Пользователь с данной почтой'
    )
def get_user(email: str, db: Session = Depends(get_db)):
    return db_user.get_user_by_email(db, email)

# Прочитать одного пользователя по id
@router.get(
    '/{id}', 
    response_model=UserDisplay, 
    summary= 'Поиск пользователя по идентификатору', 
    response_description='Пользователь с данным идентификатором'
    )
def get_user(id: int, db: Session = Depends(get_db)):
    return db_user.get_user(db, id)

# Обновить пользователя
@router.post(
    '/{id}/update', 
    summary= 'Изменение данных пользователя'
    )
def update_user(id: int, request: UserBase, db: Session = Depends(get_db)):
    return db_user.update_user(db, id, request)


# Удалить пользователя
@router.get(
    '/delete/{id}',
    summary= 'Удаление пользователя'
    )
def delete(id: int, db: Session = Depends(get_db)):
    return db_user.delete_user(db, id)