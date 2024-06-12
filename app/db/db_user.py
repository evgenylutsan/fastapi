from sqlalchemy.orm.session import Session
from app.db.hash import Hash
from app.schemas import UserBase
from app.db.models import DbUser
from fastapi import HTTPException, status


def create_user(db: Session, request: UserBase):
    new_user = DbUser(
        name = request.name,
        surname = request.surname,
        email = request.email,
        phone_number = request.phone_number,
        password = Hash.bcrypt(request.password)
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

def get_all_users(db: Session):
    return db.query(DbUser).all()

def get_user(db: Session, id: int):
    return db.query(DbUser).filter(DbUser.id == id).first()

def get_user_by_email(db: Session, email: str):
    user = db.query(DbUser).filter(DbUser.email == email).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь с данной почтой не найден")
    return user

def existing_user(db: Session, email:str):
    return db.query(DbUser).filter(DbUser.email == email).first()

def update_user(db: Session, id: int, request: UserBase):
    user = db.query(DbUser).filter(DbUser.id == id)
    user.update({
        DbUser.name: request.name,
        DbUser.surname: request.surname,
        DbUser.email: request.email,
        DbUser.phone_number: request.phone_number,
        DbUser.password: Hash.bcrypt(request.password)
    })
    db.commit()
    return 'Данные успешно изменены'

def delete_user(db: Session, id: int):
    user = db.query(DbUser).filter(DbUser.id == id).first()
    db.delete(user)
    db.commit()
    return 'Пользователь удален'