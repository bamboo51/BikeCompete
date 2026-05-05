import os
from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from app.models import db
from app.routes.auth import auth_bp
from app.routes.riders import riders_bp
from app.routes.races import races_bp
from app.routes.tasks import tasks_bp
from app.routes.leaderboard import leaderboard_bp


def create_app():
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = os.environ["DATABASE_URL"]
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["JWT_SECRET_KEY"] = os.environ["JWT_SECRET_KEY"]

    db.init_app(app)
    JWTManager(app)

    app.register_blueprint(auth_bp)
    app.register_blueprint(riders_bp)
    app.register_blueprint(races_bp)
    app.register_blueprint(tasks_bp)
    app.register_blueprint(leaderboard_bp)

    @app.route("/health")
    def health():
        return jsonify({"status": "ok"})

    return app


app = create_app()
