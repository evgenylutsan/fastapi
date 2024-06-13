from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas import SponsorBase, Sponsor
from app.db import db_sponsor

router = APIRouter(
    prefix='api/sponsor',
    tags=['sponsor']
)


# Создать спонсора
@router.post(
    '/',
    response_model=Sponsor,
    summary= 'Создание спонсора'
    )
def create_sponsor(request: Sponsor, db: Session = Depends(get_db)):
    return db_sponsor.create_sponsor(db, request)


# Прочитать всех спонсоров
@router.get(
    '/',
    summary= 'Вывод всех спонсоров'
    )
def get_all_sponsors(db: Session = Depends(get_db)):
    return db_sponsor.get_all_sponsors(db)


# Прочитать одного спонсора
@router.get(
    '/{id}',
    response_model = SponsorBase, 
    summary= 'Поиск споносра по названию' 
    )
def get_sponsor(name: str, db: Session = Depends(get_db)):
    return db_sponsor.get_sponsor(db, name)


# Обновить пользователя
@router.post(
    '/{id}/update',
    summary='Изменение информации о спонсоре'
    )
def update_sponsor(id: int, request: SponsorBase, db: Session = Depends(get_db)):
    return db_sponsor.update_sponsor(db, id, request)

@router.get(
    '/delete/{id}',
    summary= 'Удаление споносора'
    )
def delete(id: int, db: Session = Depends(get_db)):
    return db_sponsor.delete_sponsor(db, id)