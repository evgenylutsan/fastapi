from random import randint
from fastapi import APIRouter, HTTPException, Depends
from app.schemas import TicketCreate, TicketResponse
from app.db.database import get_db
from app.db.models import DBEvent, DbUser, DBTicket
from sqlalchemy.orm import Session
from sqlalchemy.exc import NoResultFound


router = APIRouter(
    prefix='/api/event',
    tags=['event']
)

@router.post("/tickets/", response_model=TicketResponse)
def purchase_ticket(ticket: TicketCreate, db: Session = Depends(get_db)):
    try:
        event = db.query(DBEvent).filter(DBEvent.headline == ticket.event_headline).one()
    except NoResultFound:
        raise HTTPException(status_code=404, detail="Event not found")
    
    try:
        user = db.query(DbUser).filter(DbUser.id == ticket.user_id).one()
    except NoResultFound:
        raise HTTPException(status_code=404, detail="User not found")

    ticket_number = randint(100000, 999999)
    
    new_ticket = DBTicket(
        user_id=ticket.user_id,
        event_id=event.id,
        event_headline=event.headline,
        event_place=event.place,
        event_date=event.date,
        event_time=event.time,
        ticket_type=ticket.ticket_type,
        ticket_number=ticket_number
    )
    
    db.add(new_ticket)
    db.commit()
    db.refresh(new_ticket)
    
    return new_ticket