from datetime import datetime, timedelta
from sqlalchemy.orm import joinedload
from app import db
from app.models.parking_garage import ParkingGarage
from app.models.parking_spot import ParkingSpot
from app.models.sensor import Sensor
from app.models.occupancy_history import OccupancyHistory

class ParkingService:

    @staticmethod
    def get_all_garages():
        garages = ParkingGarage.query.all()
        return [garage.to_dict() for garage in garages]

    @staticmethod
    def get_garage_by_id(garage_id):
        garage = ParkingGarage.query.get(garage_id)
        if not garage:
            return None
        return garage.to_dict()

    @staticmethod
    def get_garage_availability(garage_id):
        garage = ParkingGarage.query.get(garage_id)
        if not garage:
            return None

        spots = ParkingSpot.query.options(
            db.joinedload(ParkingSpot.sensor)
        ).filter_by(garage_id=garage_id).all()

        availability_by_floor = {}
        for spot in spots:
            floor = spot.floor_number
            if floor not in availability_by_floor:
                availability_by_floor[floor] = {
                    'floor_number': floor,
                    'total_spots': 0,
                    'available_spots': 0,
                    'occupied_spots': 0,
                    'spots': []
                }

            availability_by_floor[floor]['total_spots'] += 1
            if spot.is_occupied:
                availability_by_floor[floor]['occupied_spots'] += 1
            else:
                availability_by_floor[floor]['available_spots'] += 1

            availability_by_floor[floor]['spots'].append(spot.to_dict())

        return {
            'garage': garage.to_dict(),
            'floors': list(availability_by_floor.values())
        }

    @staticmethod
    def get_floor_availability(garage_id, floor_number):
        spots = ParkingSpot.query.options(
            db.joinedload(ParkingSpot.sensor)
        ).filter_by(
            garage_id=garage_id,
            floor_number=floor_number
        ).all()

        if not spots:
            return None

        available = [s.to_dict() for s in spots if not s.is_occupied]
        occupied = [s.to_dict() for s in spots if s.is_occupied]

        return {
            'floor_number': floor_number,
            'total_spots': len(spots),
            'available_spots': len(available),
            'occupied_spots': len(occupied),
            'available': available,
            'occupied': occupied
        }

    @staticmethod
    def get_spot_by_id(space_id):
        spot = ParkingSpot.query.get(space_id)
        if not spot:
            return None
        return spot.to_dict()

    @staticmethod
    def update_spot_occupancy(space_id, is_occupied):
        spot = ParkingSpot.query.get(space_id)
        if not spot:
            return None

        if spot.is_occupied != is_occupied:
            spot.is_occupied = is_occupied
            spot.last_updated = datetime.utcnow()

            garage = spot.garage
            if is_occupied:
                garage.open_spaces = max(0, garage.open_spaces - 1)
            else:
                garage.open_spaces = min(garage.total_spaces, garage.open_spaces + 1)
            garage.updated_at = datetime.utcnow()

            history = OccupancyHistory(
                space_id=space_id,
                was_occupied=is_occupied
            )
            db.session.add(history)

            db.session.commit()

        return spot.to_dict()

    @staticmethod
    def get_available_spots_by_type(garage_id, spot_type):
        spots = ParkingSpot.query.options(
            db.joinedload(ParkingSpot.sensor)
        ).filter_by(
            garage_id=garage_id,
            spot_type=spot_type,
            is_occupied=False
        ).all()

        return [spot.to_dict() for spot in spots]

    @staticmethod
    def get_occupancy_history(space_id, hours=24):
        cutoff = datetime.utcnow() - timedelta(hours=hours)

        history = OccupancyHistory.query.filter(
            OccupancyHistory.space_id == space_id,
            OccupancyHistory.timestamp >= cutoff
        ).order_by(OccupancyHistory.timestamp.desc()).all()

        return [h.to_dict() for h in history]
