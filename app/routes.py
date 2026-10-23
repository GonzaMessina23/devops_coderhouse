import os
from functools import wraps

import psycopg
from psycopg.rows import dict_row

from flask import (
    current_app, redirect, render_template, request, session, url_for
)
from werkzeug.security import check_password_hash, generate_password_hash


def get_db():
    return psycopg.connect(
        current_app.config["DATABASE_URL"],
        row_factory=dict_row
    )


def init_db():
    with get_db() as db:
        db.execute("""
            CREATE TABLE IF NOT EXISTS users (
                username TEXT PRIMARY KEY,
                password_hash TEXT NOT NULL
            )
        """)

        username = os.getenv("DEMO_USERNAME", "demo")
        password = os.getenv("DEMO_PASSWORD", "")

        if password:
            db.execute(
                """
                INSERT INTO users (username, password_hash)
                VALUES (%s, %s)
                ON CONFLICT (username) DO NOTHING
                """,
                (username, generate_password_hash(password))
            )


def login_required(view):
    @wraps(view)
    def wrapped(*args, **kwargs):
        if "username" not in session:
            return redirect(url_for("login"))
        return view(*args, **kwargs)
    return wrapped


def register_routes(app):
    with app.app_context():
        init_db()

    @app.get("/health")
    def health():
        return {"status": "ok"}, 200

    @app.route("/", methods=["GET", "POST"])
    def login():
        error = None

        if request.method == "POST":
            username = request.form.get("username", "").strip()
            password = request.form.get("password", "")

            with get_db() as db:
                user = db.execute(
                    "SELECT * FROM users WHERE username = %s",
                    (username,)
                ).fetchone()

            if user and check_password_hash(
                user["password_hash"], password
            ):
                session.clear()
                session["username"] = user["username"]
                return redirect(url_for("dashboard"))

            error = "Usuario o contraseña incorrectos."

        return render_template("login.html", error=error)

    @app.get("/dashboard")
    @login_required
    def dashboard():
        return render_template(
            "dashboard.html",
            username=session["username"]
        )

    @app.post("/logout")
    def logout():
        session.clear()
        return redirect(url_for("login"))
