from datetime import date as date_type
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class User(db.Model):
    __tablename__ = "users"
    id                   = db.Column(db.Integer, primary_key=True)
    google_sub           = db.Column(db.String(100), unique=True, nullable=False)
    email                = db.Column(db.String(200), unique=True, nullable=False)
    name                 = db.Column(db.String(200))
    total_points         = db.Column(db.Integer, default=0, nullable=False)
    total_distance_m     = db.Column(db.Integer, default=0, nullable=False)  # metres
    total_time_seconds   = db.Column(db.Integer, default=0, nullable=False)
    current_streak       = db.Column(db.Integer, default=0, nullable=False)
    longest_streak       = db.Column(db.Integer, default=0, nullable=False)
    last_activity_date   = db.Column(db.Date, nullable=True)
    daily_tasks          = db.relationship("UserDailyTask", back_populates="user")


class RandomTask(db.Model):
    """Pool of challenge/random tasks an admin can assign."""
    __tablename__ = "random_tasks"
    id           = db.Column(db.Integer, primary_key=True)
    title        = db.Column(db.String(200), nullable=False)
    description  = db.Column(db.Text)
    points       = db.Column(db.Integer, nullable=False)
    task_type    = db.Column(db.String(50), nullable=False)   # distance | time | count
    target_value = db.Column(db.Integer, nullable=False)      # metres or seconds or reps


class DailyTask(db.Model):
    """Pool of daily task templates."""
    __tablename__ = "daily_tasks"
    id           = db.Column(db.Integer, primary_key=True)
    title        = db.Column(db.String(200), nullable=False)
    description  = db.Column(db.Text)
    points       = db.Column(db.Integer, nullable=False)
    task_type    = db.Column(db.String(50), nullable=False)   # distance | time | count
    target_value = db.Column(db.Integer, nullable=False)
    assignments  = db.relationship("UserDailyTask", back_populates="daily_task")


class UserDailyTask(db.Model):
    """A DailyTask assigned to a specific user on a specific date."""
    __tablename__ = "user_daily_tasks"
    id                = db.Column(db.Integer, primary_key=True)
    user_id           = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    daily_task_id     = db.Column(db.Integer, db.ForeignKey("daily_tasks.id"), nullable=False)
    assigned_date     = db.Column(db.Date, nullable=False, default=date_type.today)
    status            = db.Column(db.String(20), default="pending")  # pending | completed
    progress_distance = db.Column(db.Integer, default=0)             # metres
    progress_time     = db.Column(db.Integer, default=0)             # seconds
    completed_at      = db.Column(db.DateTime, nullable=True)
    user              = db.relationship("User", back_populates="daily_tasks")
    daily_task        = db.relationship("DailyTask", back_populates="assignments")


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
