import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from config.config import Config

db = SQLAlchemy()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db_uri = app.config['SQLALCHEMY_DATABASE_URI']
    print(f"Database URI: {db_uri}")
    if db_uri.startswith('sqlite:///'):
        db_path = db_uri.replace('sqlite:///', '')
        print(f"Database path: {db_path}")
        db_dir = os.path.dirname(db_path)
        print(f"Database directory: {db_dir}")
        if db_dir and not os.path.exists(db_dir):
            print(f"Creating directory: {db_dir}")
            os.makedirs(db_dir, exist_ok=True)

    db.init_app(app)
    CORS(app)

    with app.app_context():
        from app.scheduler import init_scheduler
        init_scheduler(app)

    from app.routes import api_bp
    app.register_blueprint(api_bp, url_prefix='/api/v1')

    from app.models import parking_garage, parking_spot, sensor, camera, occupancy_history

    with app.app_context():
        db.create_all()
        print("Database tables created successfully")

    return app
