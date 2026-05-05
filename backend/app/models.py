from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Team(db.Model):
    __tablename__ = "teams"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    riders = db.relationship("Rider", back_populates="team")


class Rider(db.Model):
    __tablename__ = "riders"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    team_id = db.Column(db.Integer, db.ForeignKey("teams.id"), nullable=True)
    team = db.relationship("Team", back_populates="riders")
    results = db.relationship("Result", back_populates="rider")


class Race(db.Model):
    __tablename__ = "races"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    date = db.Column(db.Date, nullable=False)
    location = db.Column(db.String(200))
    results = db.relationship("Result", back_populates="race")


class Result(db.Model):
    __tablename__ = "results"
    id = db.Column(db.Integer, primary_key=True)
    rider_id = db.Column(db.Integer, db.ForeignKey("riders.id"), nullable=False)
    race_id = db.Column(db.Integer, db.ForeignKey("races.id"), nullable=False)
    position = db.Column(db.Integer)
    finish_time_seconds = db.Column(db.Integer)
    rider = db.relationship("Rider", back_populates="results")
    race = db.relationship("Race", back_populates="results")
