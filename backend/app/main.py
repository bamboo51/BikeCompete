import os
from flask import Flask, jsonify
from app.models import db
from app.routes.riders import riders_bp
from app.routes.races import races_bp


def create_app():
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = os.environ["DATABASE_URL"]
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)

    app.register_blueprint(riders_bp)
    app.register_blueprint(races_bp)

    @app.route("/health")
    def health():
        return jsonify({"status": "ok"})

    return app


app = create_app()
