from flask import jsonify, request
from app.routes import api_bp
from app.services.parking_service import ParkingService

@api_bp.route('/garages', methods=['GET'])
def get_garages():
    """
    Get all parking garages
    ---
    GET /api/v1/garages
    """
    garages = ParkingService.get_all_garages()
    return jsonify({
        'success': True,
        'count': len(garages),
        'data': garages
    }), 200

@api_bp.route('/garages/<int:garage_id>', methods=['GET'])
def get_garage(garage_id):
    """
    Get specific garage by ID
    ---
    GET /api/v1/garages/{garage_id}
    """
    garage = ParkingService.get_garage_by_id(garage_id)

    if not garage:
        return jsonify({
            'success': False,
            'error': 'Garage not found'
        }), 404

    return jsonify({
        'success': True,
        'data': garage
    }), 200

@api_bp.route('/garages/<int:garage_id>/availability', methods=['GET'])
def get_garage_availability(garage_id):
    """
    Get real-time availability for entire garage
    ---
    GET /api/v1/garages/{garage_id}/availability
    """
    availability = ParkingService.get_garage_availability(garage_id)

    if not availability:
        return jsonify({
            'success': False,
            'error': 'Garage not found'
        }), 404

    return jsonify({
        'success': True,
        'data': availability
    }), 200

@api_bp.route('/garages/<int:garage_id>/floors/<int:floor_number>', methods=['GET'])
def get_floor_availability(garage_id, floor_number):
    """
    Get availability for specific floor
    ---
    GET /api/v1/garages/{garage_id}/floors/{floor_number}
    """
    availability = ParkingService.get_floor_availability(garage_id, floor_number)

    if not availability:
        return jsonify({
            'success': False,
            'error': 'Floor not found'
        }), 404

    return jsonify({
        'success': True,
        'data': availability
    }), 200

@api_bp.route('/garages/<int:garage_id>/spots/type/<spot_type>', methods=['GET'])
def get_spots_by_type(garage_id, spot_type):
    """
    Get available spots by type (regular, handicap, staff, paid)
    ---
    GET /api/v1/garages/{garage_id}/spots/type/{spot_type}
    """
    if spot_type not in ['regular', 'handicap', 'staff', 'paid']:
        return jsonify({
            'success': False,
            'error': 'Invalid spot type'
        }), 400

    spots = ParkingService.get_available_spots_by_type(garage_id, spot_type)

    return jsonify({
        'success': True,
        'count': len(spots),
        'data': spots
    }), 200
