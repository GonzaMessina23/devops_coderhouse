import os
from flask import Flask
from dotenv import load_dotenv

load_dotenv()

def create_app():
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv(
        "SECRET_KEY", "development-only-change-me"
    )
    app.config["DATABASE_PATH"] = os.getenv(
        "DATABASE_PATH", "instance/app.db"
    )

    from app.routes import register_routes
    register_routes(app)
    return app
