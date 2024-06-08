from typing import Dict, List
from sqlalchemy.orm.session import Session
from app.schemas import EventBase, Event
from app.db.models import DBEvent, DBEventDetails, DBCalendar

def get_all_events(db: Session):
    return db.query(DBEvent).all()

def get_event(db: Session, head: str):
    event = db.query(DBEvent).filter(DBEvent.head == head).first()
    return event

def create_event(db: Session, request: Event):
    new_event = DBEvent(
        headline = request.headline,
        description = request.description,
        short_description = request.short_description,
        type = request.type,
        event_date = request.event_date,
        event_time = request.event_time,
        image = request.image,
        preview_image = request.preview_image,
        place = request.place,
        format = request.format,
        audience = request.audience
    )
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return new_event


def delete_event(db: Session, id: int):
    event = db.query(DBEvent).filter(DBEvent.id == id).first()
    db.delete(event)
    db.commit()
    return 'Спонсор удален'

