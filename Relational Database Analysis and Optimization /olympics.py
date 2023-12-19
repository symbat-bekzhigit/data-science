import configparser
from operator import itemgetter

import sqlalchemy
from sqlalchemy import create_engine

# columns and their types, including fk relationships
from sqlalchemy import Column, Integer, Float, String, DateTime
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship

# declarative base, session, and datetime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# configuring your database connection
config = configparser.ConfigParser()
config.read('config.ini')
u, pw, host, db = itemgetter('username', 'password', 'host', 'database')(config['db'])
dsn = f'postgresql://{u}:{pw}@{host}/{db}'
print(f'using dsn: {dsn}')

# SQLAlchemy engine, base class and session setup
engine = create_engine(dsn, echo=True)
Base = declarative_base()
Session = sessionmaker(engine)
session = Session()


# TODO: Write classes and code here

#do the additional imports
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy import select, and_


# Define the Base Class
# class Base(DeclarativeBase):
#     pass

# Define the ORM classes for athlete_event and noc_region
class AthleteEvent(Base):
    __tablename__ = 'athlete_event'

    athlete_event_id: Mapped[int] = mapped_column(primary_key=True)
    id: Mapped[int] = mapped_column()
    name: Mapped[str] = mapped_column()
    sex: Mapped[str] = mapped_column()
    age: Mapped[int] = mapped_column()
    height: Mapped[int] = mapped_column()
    weight: Mapped[int] = mapped_column()
    team: Mapped[str] = mapped_column()
    noc: Mapped[str] = mapped_column(ForeignKey('noc_region.noc'))
    games: Mapped[str] = mapped_column() 
    year: Mapped[int] = mapped_column() 
    season: Mapped[str] = mapped_column()
    city: Mapped[str] = mapped_column()
    sport: Mapped[str] = mapped_column() 
    event: Mapped[str] = mapped_column() 
    medal: Mapped[str] = mapped_column()

    noc_region = relationship("NOCRegion", back_populates="athlete_events")

    def __str__(self):
        return f"Athlete: {self.name}, NOC: {self.noc}, Season: {self.season}, Year: {self.year, }Event: {self.event}, Medal: {self.medal}"

    def __repr__(self):
        return self.__str__()


class NOCRegion(Base):
    __tablename__ = 'noc_region'

    noc: Mapped[str] = mapped_column(primary_key=True)
    region: Mapped[str] = mapped_column()
    note: Mapped[str] = mapped_column()

    athlete_events = relationship("AthleteEvent", back_populates="noc_region")

    def __str__(self):
        return f"NOC: {self.noc}, Region: {self.region}, Note: {self.note}"


# create tables
Base.metadata.create_all(engine)

# Step 3: Insert a new record into the athlete_event table

new_athlete_data = {
    'athlete_event_id': 271117, # 271117 because in our athlete_event table there are currently 271116 rows
    'id': 271117,
    'name': 'Yuto Horigome',
    'sex': 'M',
    'age': 21,
    # 'height':
    # 'weight':
    'team': 'Japan',
    'noc': 'JPN',
    'games': '2020 Summer',
    'year': 2020,
    'season': 'Summer',
    'city': 'Tokyo',
    'sport': 'Skateboarding',
    'event': 'Skateboarding, Street, Men',
    'medal': 'Gold'

}

new_athlete = AthleteEvent(**new_athlete_data)

session.add(new_athlete)
session.commit()



# Step 4: Perform the specified search

# Define the conditions for the search
conditions = and_(
    AthleteEvent.noc == 'JPN',
    AthleteEvent.year >= 2016,
    AthleteEvent.medal == 'Gold'
)

# Construct the query
query = (
    select(AthleteEvent.name, NOCRegion.region, AthleteEvent.event, AthleteEvent.year, AthleteEvent.season)
    .join_from(AthleteEvent,NOCRegion)
    .where(conditions)
)

# Execute the query and iterate through the results
results = session.execute(query)

for result in results:
    print(
        f"Name: {result.name}, "
        f"Region: {result.region}, "
        f"Event: {result.event}, "
        f"Year: {result.year}, "
        f"Season: {result.season}"
    )


session.close()

