from datetime import datetime
from app import db

class ParkingSpot(db.Model):
    __tablename__ = 'parking_spot'

    space_id = db.Column(db.Integer, primary_key=True)
    garage_id = db.Column(db.Integer, db.ForeignKey('parking_garage.garage_id'), nullable=False)
    floor_number = db.Column(db.Integer, nullable=False)
    spot_number = db.Column(db.String(10), nullable=False)
    is_occupied = db.Column(db.Boolean, default=False)
    spot_type = db.Column(db.String(20), default='regular')  
    last_updated = db.Column(db.DateTime, default=datetime.utcnow)

    sensor = db.relationship('Sensor', backref='parking_spot', uselist=False, cascade='all, delete-orphan')
    history = db.relationship('OccupancyHistory', backref='parking_spot', lazy=True, cascade='all, delete-orphan')

    __table_args__ = (
        db.UniqueConstraint('garage_id', 'floor_number', 'spot_number', name='unique_spot'),
    )

    def to_dict(self):
        return {
            'space_id': self.space_id,
            'garage_id': self.garage_id,
            'floor_number': self.floor_number,
            'spot_number': self.spot_number,
            'is_occupied': self.is_occupied,
            'spot_type': self.spot_type,
            'last_updated': self.last_updated.isoformat(),
            'sensor_status': self.sensor.status if self.sensor else 'no_sensor'
        }
