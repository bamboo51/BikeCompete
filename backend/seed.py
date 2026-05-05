#!/usr/bin/env python
"""
Seed the database with dummy data for development/testing.

Usage:
  docker compose exec backend python seed.py           # seed (skips if already seeded)
  docker compose exec backend python seed.py --reset   # wipe and re-seed
"""

import sys
from datetime import date, datetime, timedelta
from app.main import create_app
from app.models import (
    db, User, Team, Rider, Race, Result,
    DailyTask, RandomTask, UserDailyTask,
)

app = create_app()

with app.app_context():
    if User.query.count() > 0:
        if "--reset" not in sys.argv:
            print("Already seeded. Use --reset to wipe and re-seed.")
            sys.exit(0)
        print("Resetting seed data...")
        UserDailyTask.query.delete()
        Result.query.delete()
        Rider.query.delete()
        Race.query.delete()
        Team.query.delete()
        RandomTask.query.delete()
        DailyTask.query.delete()
        User.query.delete()
        db.session.commit()

    # ------------------------------------------------------------------ #
    # Users                                                                #
    # ------------------------------------------------------------------ #
    today = date.today()

    alice = User(
        google_sub="fake_sub_alice",
        email="alice@test.com",
        name="Alice",
        total_points=340,
        total_distance_m=87_000,
        total_time_seconds=18_000,
        current_streak=5,
        longest_streak=12,
        last_activity_date=today,
    )
    bob = User(
        google_sub="fake_sub_bob",
        email="bob@test.com",
        name="Bob",
        total_points=210,
        total_distance_m=42_000,
        total_time_seconds=10_800,
        current_streak=14,
        longest_streak=14,
        last_activity_date=today,
    )
    charlie = User(
        google_sub="fake_sub_charlie",
        email="charlie@test.com",
        name="Charlie",
        total_points=80,
        total_distance_m=15_000,
        total_time_seconds=3_600,
        current_streak=1,
        longest_streak=3,
        last_activity_date=today,
    )
    diana = User(
        google_sub="fake_sub_diana",
        email="diana@test.com",
        name="Diana",
        total_points=0,
        total_distance_m=0,
        total_time_seconds=0,
        current_streak=0,
        longest_streak=0,
        last_activity_date=None,
    )
    db.session.add_all([alice, bob, charlie, diana])
    db.session.commit()

    # ------------------------------------------------------------------ #
    # Teams & Riders                                                       #
    # ------------------------------------------------------------------ #
    team_alpha = Team(name="Team Alpha")
    team_beta  = Team(name="Team Beta")
    db.session.add_all([team_alpha, team_beta])
    db.session.commit()

    riders = [
        Rider(name="Alice Rider",   team=team_alpha),
        Rider(name="Bob Rider",     team=team_alpha),
        Rider(name="Charlie Rider", team=team_beta),
        Rider(name="Diana Rider",   team=team_beta),
    ]
    db.session.add_all(riders)
    db.session.commit()

    # ------------------------------------------------------------------ #
    # Races & Results                                                      #
    # ------------------------------------------------------------------ #
    mountain_stage = Race(
        name="Mountain Stage",
        date=today - timedelta(days=14),
        location="Alps",
    )
    city_sprint = Race(
        name="City Sprint",
        date=today - timedelta(days=7),
        location="Downtown",
    )
    db.session.add_all([mountain_stage, city_sprint])
    db.session.commit()

    db.session.add_all([
        Result(rider=riders[0], race=mountain_stage, position=1, finish_time_seconds=7_200),
        Result(rider=riders[1], race=mountain_stage, position=2, finish_time_seconds=7_350),
        Result(rider=riders[2], race=mountain_stage, position=3, finish_time_seconds=7_500),
        Result(rider=riders[3], race=mountain_stage, position=4, finish_time_seconds=7_800),
        Result(rider=riders[2], race=city_sprint,    position=1, finish_time_seconds=3_600),
        Result(rider=riders[0], race=city_sprint,    position=2, finish_time_seconds=3_700),
        Result(rider=riders[3], race=city_sprint,    position=3, finish_time_seconds=3_850),
        Result(rider=riders[1], race=city_sprint,    position=4, finish_time_seconds=4_000),
    ])
    db.session.commit()

    # ------------------------------------------------------------------ #
    # Task pools                                                           #
    # ------------------------------------------------------------------ #
    daily_tasks = [
        DailyTask(title="Morning Ride",       description="Complete a 10 km ride",    points=50, task_type="distance", target_value=10_000),
        DailyTask(title="Endurance Session",  description="Ride for 1 hour",          points=60, task_type="time",     target_value=3_600),
        DailyTask(title="Sprint Intervals",   description="Complete 5 km of sprints", points=40, task_type="distance", target_value=5_000),
        DailyTask(title="Recovery Spin",      description="Easy 30-minute spin",      points=20, task_type="time",     target_value=1_800),
    ]
    random_tasks = [
        RandomTask(title="Century Ride",  description="Ride 100 km in one go",     points=500, task_type="distance", target_value=100_000),
        RandomTask(title="Hour of Power", description="Max effort for 60 minutes", points=300, task_type="time",     target_value=3_600),
        RandomTask(title="Hill Climber",  description="Climb 1000 m elevation",    points=400, task_type="count",    target_value=1_000),
    ]
    db.session.add_all(daily_tasks + random_tasks)
    db.session.commit()

    # ------------------------------------------------------------------ #
    # User daily task assignments                                          #
    # ------------------------------------------------------------------ #
    def make_udt(user, task, days_ago, status, dist=0, time=0):
        completed_at = None
        if status == "completed":
            dist = dist or task.target_value if task.task_type == "distance" else 0
            time = time or task.target_value if task.task_type == "time" else 0
            completed_at = datetime.utcnow() - timedelta(days=days_ago)
        return UserDailyTask(
            user=user,
            daily_task=task,
            assigned_date=today - timedelta(days=days_ago),
            status=status,
            progress_distance=dist,
            progress_time=time,
            completed_at=completed_at,
        )

    assignments = [
        # Alice — today: 1 completed, 1 in progress
        make_udt(alice, daily_tasks[0], 0, "completed"),
        make_udt(alice, daily_tasks[1], 0, "pending", time=1_200),  # 33% done
        # Bob — today: 2 pending
        make_udt(bob, daily_tasks[2], 0, "pending"),
        make_udt(bob, daily_tasks[3], 0, "pending"),
        # Charlie — today: 1 completed
        make_udt(charlie, daily_tasks[0], 0, "completed"),
        # Diana — today: 1 pending, not started
        make_udt(diana, daily_tasks[0], 0, "pending"),
        # Historical completions for streak display
        make_udt(alice,   daily_tasks[0], 1, "completed"),
        make_udt(alice,   daily_tasks[0], 2, "completed"),
        make_udt(bob,     daily_tasks[2], 1, "completed"),
        make_udt(bob,     daily_tasks[3], 2, "completed"),
        make_udt(charlie, daily_tasks[1], 3, "completed"),
    ]
    db.session.add_all(assignments)
    db.session.commit()

    print("Seeded:")
    print(f"  {User.query.count()} users        (IDs 1-{User.query.count()})")
    print(f"  {Team.query.count()} teams")
    print(f"  {Rider.query.count()} riders")
    print(f"  {Race.query.count()} races        with {Result.query.count()} results")
    print(f"  {DailyTask.query.count()} daily task templates")
    print(f"  {RandomTask.query.count()} random task templates")
    print(f"  {UserDailyTask.query.count()} user task assignments")
    print()
    print("Dev tokens (FLASK_ENV=development only):")
    for u in User.query.all():
        print(f"  GET /auth/dev-token/{u.id}  →  {u.name}")
