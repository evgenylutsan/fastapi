from sqlalchemy.orm.session import Session
from app.schemas import SpeakerBase, Speaker
from app.db.models import DBSpeaker

def get_all_speakers(db: Session):
    return db.query(DBSpeaker).all()

def get_speaker(db: Session, surname: str):
    return db.query(DBSpeaker).filter(DBSpeaker.surname == surname).first()

def create_speaker(db: Session, request: Speaker):
    new_speaker = DBSpeaker(
        name = request.name,
        surname = request.surname,
        role = request.role,
        image = request.image,
        description = request.description,
    )
    db.add(new_speaker)
    db.commit()
    db.refresh(new_speaker)
    return new_speaker

def upadte_speaker(db: Session, id: int, request: Speaker):
    speaker = db.query(DBSpeaker).filter(DBSpeaker.id == id)
    speaker.update({
        DBSpeaker.name: request.name,
        DBSpeaker.surname: request.surname,
        DBSpeaker.role: request.role,
        DBSpeaker.image: request.image,
        DBSpeaker.description: request.description,
    })
    db.commit()
    return 'Данные спикера успешно изменены'
    
    
def delete_speaker(db: Session, id: int):
    speaker = db.query(DBSpeaker).filter(DBSpeaker.id == id).first()
    db.delete(speaker)
    db.commit()
    return 'Спикер удален'