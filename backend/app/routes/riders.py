from flask import Blueprint, jsonify, request
from app.models import db, Rider, Team

riders_bp = Blueprint("riders", __name__, url_prefix="/riders")


@riders_bp.route("/", methods=["GET"])
def list_riders():
    riders = Rider.query.all()
    return jsonify([
        {"id": r.id, "name": r.name, "team": r.team.name if r.team else None}
        for r in riders
    ])


@riders_bp.route("/<int:rider_id>", methods=["GET"])
def get_rider(rider_id):
    rider = Rider.query.get_or_404(rider_id)
    return jsonify({
        "id": rider.id,
        "name": rider.name,
        "team": rider.team.name if rider.team else None,
    })


@riders_bp.route("/", methods=["POST"])
def create_rider():
    data = request.get_json()
    rider = Rider(name=data["name"], team_id=data.get("team_id"))
    db.session.add(rider)
    db.session.commit()
    return jsonify({"id": rider.id, "name": rider.name}), 201
