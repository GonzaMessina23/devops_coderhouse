import os
from urllib.parse import quote

from flask import Flask
from dotenv import load_dotenv

load_dotenv()


def create_app():
    app = Flask(__name__)

    app.config["SECRET_KEY"] = os.getenv(
        "SECRET_KEY", "development-only-change-me"
    )

    database_url = os.getenv("DATABASE_URL")

    if not database_url:
        user = os.getenv("POSTGRES_USER", "login_user")
        password = quote(
            os.environ["POSTGRES_PASSWORD"],
            safe=""
        )
        host = os.getenv("POSTGRES_HOST", "postgres")
        port = os.getenv("POSTGRES_PORT", "5432")
        database = os.getenv("POSTGRES_DB", "login_db")

        database_url = (
            f"postgresql://{user}:{password}@{host}:{port}/{database}"
        )

    app.config["DATABASE_URL"] = database_url

    from app.routes import register_routes
    register_routes(app)

    return app
