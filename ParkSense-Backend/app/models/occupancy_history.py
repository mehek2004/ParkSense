from datetime import datetime
from app import db

class OccupancyHistory(db.Model):
    __tablename__ = 'occupancy_history'

    history_id = db.Column(db.Integer, primary_key=True)
    space_id = db.Column(db.Integer, db.ForeignKey('parking_spot.space_id'), nullable=False)
    was_occupied = db.Column(db.Boolean, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'history_id': self.history_id,
            'space_id': self.space_id,
            'was_occupied': self.was_occupied,
            'timestamp': self.timestamp.isoformat()
        }
