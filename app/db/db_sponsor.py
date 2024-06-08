from sqlalchemy.orm.session import Session
from app.schemas import SponsorBase, Sponsor
from app.db.models import DBSponsor

def create_sponsor(db: Session, request: Sponsor):
    new_sponsor = DBSponsor(
        image = request.image,
        name = request.name,
        description = request.description,
    )
    db.add(new_sponsor)
    db.commit()
    db.refresh(new_sponsor)
    return new_sponsor

def get_all_sponsors(db: Session):
    return db.query(DBSponsor).all()

def get_sponsor(db: Session, name: str):
    return db.query(DBSponsor).filter(DBSponsor.name == name).first()

def update_sponsor(db: Session, id: int, request: Sponsor):
    sponsor = db.query(DBSponsor).filter(DBSponsor.id == id)
    sponsor.update({
        DBSponsor.image: request.image,
        DBSponsor.name: request.name,
        DBSponsor.description: request.description,
    })
    db.commit()
    return 'Данные спонсора успешно изменены'

def delete_sponsor(db: Session, id: int):
    sponsor = db.query(DBSponsor).filter(DBSponsor.id == id).first()
    db.delete(sponsor)
    db.commit()
    return 'Спонсор удален'