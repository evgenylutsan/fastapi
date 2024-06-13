from fastapi import APIRouter, HTTPException, status, Response, Depends
from app.db.database import get_db
from app.db import db_event, models
from app.schemas import EventBase, UserBase, Event
from typing import List
from sqlalchemy.orm import Session, relationship, joinedload
from app.auth.oauth2 import get_current_user, oauth2_scheme

router = APIRouter(
    prefix='/api/event',
    tags=['event']
)


# Получить список всех мероприятий
@router.get('/', 
            response_model=List[Event],
            summary= 'Список всех мероприятий'
            )
def get_all_events(db: Session = Depends(get_db)):
    return db_event.get_all_events(db)

# Получить мероприятие по названию
@router.get(
            '/{head}',
            response_model=Event, 
            summary= 'Поиск мероприятия по названию', 
            response_description='Мероприятие с данным названием'
            )
def get_event(head: str, db: Session = Depends(get_db)):
    return db_event.get_event(db, head)

# Создать мероприятие
@router.post(
            '/create',
            response_model=Event, 
            summary= 'Создание мероприятия'
            )
def create_event(request: Event, db: Session = Depends(get_db)):
    return {
        'data': db_event.create_event(db, request)
    }
    
# Удалить мероприятие
@router.get(
    '/delete/{id}',
    summary='Удаление мероприятия'
    )
def delete(id: int, db: Session = Depends(get_db)):
    return db_event.delete_event(db, id)




















# @router.get('/{id}/comments/{comment_id}', tags=['comment'])
# def get_comment(id: int, comment_id: int, valid: bool = True, username: Optional[str] = None):
#     return {'message': f'event_id {id}, comment_id {comment_id}, valid {valid}, username {username}'}

# class EventType(str, Enum):
#     short = 'short'
#     story = 'story'
    
# @router.get('/type/{type}')
# def get_event_type(type: EventType):
#     return {'message': f'Blog type {type}'}

# @router.get('/{id}', status_code=status.HTTP_200_OK)
# def get_event(id: int, response: Response, req_parameter: dict = Depends(required_funcionality)):
#     if id > 5:
#         response.status_code = status.HTTP_404_NOT_FOUND
#         return {'error': f'Event {id} not fornd'}
#     else:
#         response.status_code = status.HTTP_200_OK
#         return {'message': f'Event with id {id}'}