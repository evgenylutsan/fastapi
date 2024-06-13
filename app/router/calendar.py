from fastapi import APIRouter, HTTPException, status, Depends
from app.db.database import get_db
from app.db import db_calendar
from app.schemas import EventCalendar
from typing import List
from sqlalchemy.orm import Session


router = APIRouter(
    prefix='/api/calendar',
    tags=['calendar']
)

# Страница календаря
@router.get(
        '/',
        response_model=List[EventCalendar],
        summary='Календарь событий'  
        )
async def get_all_calendar(db: Session = Depends(get_db)):
    return db_calendar.get_all_calendar(db)

# Поиск события в календаре
@router.get(
        '/{event_headline}',
        response_model=EventCalendar,
        summary='Поиск события в календаре по названию'
        )
def get_event_calendar(headline: str ,db: Session = Depends(get_db)):
    calendar = db_calendar.get_calendar(db, headline)
    if not calendar:
        return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Событие с данным названием не найдено')
    
    return calendar