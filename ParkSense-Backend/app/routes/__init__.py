from flask import Blueprint

api_bp = Blueprint('api', __name__)

from app.routes import garage_routes, sensor_routes, spot_routes
