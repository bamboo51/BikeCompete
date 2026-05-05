from datetime import datetime, date
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import db, User, UserDailyTask, DailyTask

tasks_bp = Blueprint("tasks", __name__, url_prefix="/tasks")


@tasks_bp.route("/today", methods=["GET"])
@jwt_required()
def get_today_tasks():
    user_id = int(get_jwt_identity())
    tasks = (
        UserDailyTask.query
        .filter_by(user_id=user_id, assigned_date=date.today())
        .all()
    )
    return jsonify([_serialize(t) for t in tasks])


@tasks_bp.route("/<int:task_id>/progress", methods=["PATCH"])
@jwt_required()
def update_progress(task_id):
    user_id = int(get_jwt_identity())
    udt = UserDailyTask.query.filter_by(id=task_id, user_id=user_id).first_or_404()

    if udt.status == "completed":
        return jsonify({"error": "task already completed"}), 400

    data = request.get_json()
    udt.progress_distance += data.get("distance_m", 0)
    udt.progress_time     += data.get("time_seconds", 0)

    target = udt.daily_task.target_value
    task_type = udt.daily_task.task_type
    progress = udt.progress_distance if task_type == "distance" else udt.progress_time

    if progress >= target:
        udt.status = "completed"
        udt.completed_at = datetime.utcnow()
        _apply_completion(udt.user, udt.daily_task, udt)

    db.session.commit()
    return jsonify(_serialize(udt))


def _apply_completion(user: User, task: DailyTask, udt: UserDailyTask):
    user.total_points       += task.points
    user.total_distance_m   += udt.progress_distance
    user.total_time_seconds += udt.progress_time
    _update_streak(user)


def _update_streak(user: User):
    today = date.today()
    if user.last_activity_date == today:
        return  # already credited today
    if user.last_activity_date and (today - user.last_activity_date).days == 1:
        user.current_streak += 1
    else:
        user.current_streak = 1
    user.longest_streak    = max(user.longest_streak, user.current_streak)
    user.last_activity_date = today


def _serialize(udt: UserDailyTask):
    return {
        "id":                udt.id,
        "title":             udt.daily_task.title,
        "description":       udt.daily_task.description,
        "task_type":         udt.daily_task.task_type,
        "target_value":      udt.daily_task.target_value,
        "points":            udt.daily_task.points,
        "status":            udt.status,
        "progress_distance": udt.progress_distance,
        "progress_time":     udt.progress_time,
        "assigned_date":     udt.assigned_date.isoformat(),
        "completed_at":      udt.completed_at.isoformat() if udt.completed_at else None,
    }
