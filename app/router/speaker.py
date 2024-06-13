from typing import List
from fastapi import APIRouter, Depends
from app.schemas import SpeakerBase, Speaker
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db import db_speaker

router = APIRouter(
    prefix='api/speaker',
    tags=['speaker']
)

# Создать спикера
@router.post(
    '/',
    response_model=Speaker,
    summary= 'Создание записи в таблицу спикеров'
    )
def create_speaker(request: Speaker, db: Session = Depends(get_db)):
    return db_speaker.create_speaker(db, request)

# Прочитать всех спикеров
@router.get(
    '/',
    response_model=List[SpeakerBase],
    summary= 'Получение списка спикеров'
    )
def get_all_speakers(db: Session = Depends(get_db)):
    return db_speaker.get_all_speakers(db)

# Прочитать одного пользователя
@router.get(
    '/{id}',
    response_model=SpeakerBase,
    summary= 'Получение спикера по фамилии'
    )
def get_speaker(surname: str, db: Session = Depends(get_db)):
    return db_speaker.get_speaker(db, surname)

# Обновить информацию о спикере
@router.post(
    '/{id}/update',
    summary= 'Обновить информацию о спикере'
    )
def update_speaker(id: int, request: SpeakerBase, db: Session = Depends(get_db)):
    return db_speaker.upadte_speaker(db, id, request)

# Удалить спикера
@router.get(
    '/delete/{id}',
    summary= 'Удаление пользователя'
    )
def delete(id: int, db: Session = Depends(get_db)):
    return db_speaker.delete_speaker(db, id)