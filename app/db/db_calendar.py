from sqlalchemy.orm.session import Session
from app.db.models import DBCalendar

def get_all_calendar(db: Session):
    return db.query(DBCalendar).all()

def get_calendar(db: Session, headline: str):
    calendar = db.query(DBCalendar).filter(DBCalendar.event_headline == headline).first()
    return calendar