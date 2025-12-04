from datetime import datetime
from app import db

class ParkingGarage(db.Model):
    __tablename__ = 'parking_garage'

    garage_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    address = db.Column(db.String(255), nullable=False)
    total_floors = db.Column(db.Integer, nullable=False)
    total_spaces = db.Column(db.Integer, nullable=False)
    open_spaces = db.Column(db.Integer, default=0)
    latitude = db.Column(db.Float, nullable=True)
    longitude = db.Column(db.Float, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    parking_spots = db.relationship('ParkingSpot', backref='garage', lazy=True, cascade='all, delete-orphan')
    cameras = db.relationship('Camera', backref='garage', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'garage_id': self.garage_id,
            'name': self.name,
            'address': self.address,
            'total_floors': self.total_floors,
            'total_spaces': self.total_spaces,
            'open_spaces': self.open_spaces,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'occupancy_rate': round((1 - self.open_spaces / self.total_spaces) * 100, 2) if self.total_spaces > 0 else 0,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
