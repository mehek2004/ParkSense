from datetime import datetime
from app import db

class Sensor(db.Model):
    __tablename__ = 'sensor'

    sensor_id = db.Column(db.Integer, primary_key=True)
    parking_space_id = db.Column(db.Integer, db.ForeignKey('parking_spot.space_id'), nullable=False, unique=True, index=True)
    status = db.Column(db.String(20), default='active', index=True)  
    last_reading = db.Column(db.Float)
    battery_level = db.Column(db.Integer, default=100)
    last_ping = db.Column(db.DateTime, default=datetime.utcnow)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'sensor_id': self.sensor_id,
            'parking_space_id': self.parking_space_id,
            'status': self.status,
            'last_reading': self.last_reading,
            'battery_level': self.battery_level,
            'last_ping': self.last_ping.isoformat(),
            'created_at': self.created_at.isoformat()
        }
