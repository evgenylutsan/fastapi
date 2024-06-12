from app.db.database import Base
from sqlalchemy import Column, Integer, String, Date, VARCHAR, Time
from sqlalchemy.sql.schema import ForeignKey
from sqlalchemy.orm import relationship

class DbUser(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    surname = Column(String)
    email = Column(VARCHAR)
    phone_number = Column(VARCHAR)
    password = Column(VARCHAR)
    
class DBEvent(Base):
    __tablename__ = 'event'
    id = Column(Integer, primary_key=True, index=True)
    headline = Column(VARCHAR)
    description = Column(VARCHAR)
    short_description = Column(VARCHAR)
    type = Column(VARCHAR)
    event_date = Column(Date)
    event_time = Column(Time)
    image = Column(VARCHAR)
    preview_image = Column(VARCHAR)
    place = Column(VARCHAR)
    format = Column(VARCHAR)
    audience = Column(VARCHAR)
    
class DBSpeaker(Base):
    __tablename__ = 'speakers'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    surname = Column(String)
    role = Column(String)
    image = Column(VARCHAR)
    description = Column(VARCHAR)
    
class DBSponsor(Base):
    __tablename__ = 'partners'
    id = Column(Integer, primary_key=True, index=True)
    image = Column(VARCHAR)
    name = Column(VARCHAR)
    description = Column(VARCHAR)
    
class DBEventDetails(Base):
    __tablename__ = 'event_details'
    event_id = Column(Integer, primary_key=True)
    event_headline = Column(VARCHAR)
    event_image = Column(VARCHAR)
    event_type = Column(VARCHAR)
    event_description = Column(VARCHAR)
    event_short_description = Column(VARCHAR)
    event_format = Column(VARCHAR)
    event_audience = Column(VARCHAR)
    event_date = Column(Date)
    event_place = Column(VARCHAR)
    speaker_id = Column(Integer)
    speaker_name = Column(String)
    speaker_surname = Column(String)
    speaker_role = Column(String)
    speaker_image = Column(VARCHAR)
    speaker_description = Column(VARCHAR)
    partner_id = Column(Integer)
    partners_image = Column(VARCHAR)
    partners_name = Column(VARCHAR)
    partners_description = Column(VARCHAR)

class DBCalendar(Base):
    __tablename__ = 'calendar'
    event_id = Column(Integer, primary_key=True)
    event_headline = Column(VARCHAR)
    event_short_description = Column(VARCHAR)
    event_image_preview = Column(VARCHAR)
    event_type = Column(VARCHAR)
    event_date = Column(Date)