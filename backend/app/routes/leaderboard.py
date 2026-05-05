from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required
from app.models import db, User, UserDailyTask

leaderboard_bp = Blueprint("leaderboard", __name__, url_prefix="/leaderboard")

VALID_METRICS = {
    "points":    User.total_points,
    "distance":  User.total_distance_m,
    "time":      User.total_time_seconds,
    "streak":    User.current_streak,
}


@leaderboard_bp.route("/", methods=["GET"])
@jwt_required()
def get_leaderboard():
    metric = request.args.get("metric", "points")
    if metric not in VALID_METRICS:
        return jsonify({"error": f"metric must be one of {list(VALID_METRICS)}"}), 400

    limit = min(int(request.args.get("limit", 20)), 100)
    column = VALID_METRICS[metric]

    users = (
        User.query
        .order_by(column.desc())
        .limit(limit)
        .all()
    )

    return jsonify([
        {
            "rank":              i + 1,
            "user_id":          u.id,
            "name":             u.name,
            "points":           u.total_points,
            "distance_km":      round(u.total_distance_m / 1000, 2),
            "time_hours":       round(u.total_time_seconds / 3600, 2),
            "current_streak":   u.current_streak,
            "longest_streak":   u.longest_streak,
        }
        for i, u in enumerate(users)
    ])
