from datetime import datetime
from app import db

class Camera(db.Model):
    __tablename__ = 'camera'

    camera_id = db.Column(db.Integer, primary_key=True)
    garage_id = db.Column(db.Integer, db.ForeignKey('parking_garage.garage_id'), nullable=False)
    floor_number = db.Column(db.Integer, nullable=False)
    status = db.Column(db.String(20), default='active')  
    last_ping = db.Column(db.DateTime, default=datetime.utcnow)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'camera_id': self.camera_id,
            'garage_id': self.garage_id,
            'floor_number': self.floor_number,
            'status': self.status,
            'last_ping': self.last_ping.isoformat(),
            'created_at': self.created_at.isoformat()
        }
