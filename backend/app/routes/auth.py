import os
from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from app.models import db, User

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")

GOOGLE_CLIENT_ID = os.environ["GOOGLE_CLIENT_ID"]


@auth_bp.route("/dev-token/<int:user_id>", methods=["GET"])
def dev_token(user_id):
    """Returns a JWT for any user by ID. Only available in development."""
    if os.environ.get("FLASK_ENV") != "development":
        return jsonify({"error": "not available in production"}), 403
    user = User.query.get_or_404(user_id)
    token = create_access_token(identity=str(user.id))
    return jsonify({"token": token, "user": {"id": user.id, "name": user.name}})


@auth_bp.route("/google", methods=["POST"])
def google_login():
    token = request.get_json().get("id_token")
    if not token:
        return jsonify({"error": "id_token required"}), 400

    try:
        idinfo = id_token.verify_oauth2_token(
            token,
            google_requests.Request(),
            GOOGLE_CLIENT_ID,
        )
    except ValueError as e:
        return jsonify({"error": f"Invalid token: {e}"}), 401

    user = User.query.filter_by(google_sub=idinfo["sub"]).first()
    if not user:
        user = User(
            google_sub=idinfo["sub"],
            email=idinfo["email"],
            name=idinfo.get("name"),
        )
        db.session.add(user)
        db.session.commit()

    jwt = create_access_token(identity=str(user.id))
    return jsonify({"token": jwt, "user": {"id": user.id, "name": user.name, "email": user.email}})
