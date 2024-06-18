from datetime import date, time
from typing import List
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy import Date, Time


class UserBase(BaseModel):
    id:int
    name: str
    surname: str
    email: EmailStr
    phone_number: str
    password: str
    
# Регистрация пользователя
class User(BaseModel):
    name: str
    surname: str
    email: EmailStr
    phone_number: str
    password: str
   
# Авторизация пользователя
class UserAuth(BaseModel):
    email_login: EmailStr
    password_login: str
    
# Вывод информации о пользователе
class UserDisplay(BaseModel):
    name:str
    surname: str
    email: EmailStr
    class Config():
        from_attributes = True

class SpeakerBase(BaseModel):
    id: int
    name: str
    surname: str
    role: str
    image: str
    description: str

class SponsorBase(BaseModel):
    id: int
    image: str
    name: str
    description: str


# Speaker внутри EventDisplay
class Speaker(BaseModel):
    name: str
    surname: str
    role: str
    image: str
    description: str
    class Config():
        from_attributes = True
        

# Sponsor внутри EventDisplay
class Sponsor(BaseModel):
    image: str
    name: str
    description: str
    class Config():
        from_attributes = True

class EventBase(BaseModel):
    id: int
    headline: str
    description: str
    short_description: str
    type: str
    event_date: date
    event_time: time
    image: str
    preview_image: str
    place: str
    format: str
    audience: str
    
# Вывод информации о мероприятии
class Event(BaseModel):
    headline: str
    description: str
    short_description: str
    type: str
    event_date: date
    event_time: time
    image: str
    preview_image: str
    place: str
    format: str
    audience: str
    class Config():
        from_attributes = True
        
class EventCalendar(BaseModel):
    event_headline: str
    event_short_description: str
    event_image_preview: str
    event_type: str
    event_date: date
        
class TicketCreate(BaseModel):
    event_headline: str
    ticket_type: str = Field(..., regex="^(Делегат|Партнер|Гость)$")

class TicketResponse(BaseModel):
    id: int
    user_id: int
    event_id: int
    event_headline: str
    event_place: str
    event_date: Date
    event_time: Time
    ticket_type: str
    ticket_number: int
