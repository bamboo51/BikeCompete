from flask import Blueprint, jsonify, request
from app.models import db, Race

races_bp = Blueprint("races", __name__, url_prefix="/races")


@races_bp.route("/", methods=["GET"])
def list_races():
    races = Race.query.order_by(Race.date.desc()).all()
    return jsonify([
        {"id": r.id, "name": r.name, "date": r.date.isoformat(), "location": r.location}
        for r in races
    ])


@races_bp.route("/<int:race_id>", methods=["GET"])
def get_race(race_id):
    race = Race.query.get_or_404(race_id)
    return jsonify({
        "id": race.id,
        "name": race.name,
        "date": race.date.isoformat(),
        "location": race.location,
        "results": [
            {
                "position": res.position,
                "rider": res.rider.name,
                "finish_time_seconds": res.finish_time_seconds,
            }
            for res in sorted(race.results, key=lambda x: x.position or 9999)
        ],
    })


@races_bp.route("/", methods=["POST"])
def create_race():
    data = request.get_json()
    from datetime import date
    race = Race(
        name=data["name"],
        date=date.fromisoformat(data["date"]),
        location=data.get("location"),
    )
    db.session.add(race)
    db.session.commit()
    return jsonify({"id": race.id, "name": race.name}), 201
