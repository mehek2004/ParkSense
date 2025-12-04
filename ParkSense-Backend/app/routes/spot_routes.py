from flask import jsonify, request
from app.routes import api_bp
from app.services.parking_service import ParkingService

@api_bp.route('/spots/<int:space_id>', methods=['GET'])
def get_spot(space_id):
    spot = ParkingService.get_spot_by_id(space_id)

    if not spot:
        return jsonify({
            'success': False,
            'error': 'Parking spot not found'
        }), 404

    return jsonify({
        'success': True,
        'data': spot
    }), 200

@api_bp.route('/spots/<int:space_id>/occupancy', methods=['PUT'])
def update_spot_occupancy(space_id):
    data = request.get_json()

    if not data or 'is_occupied' not in data:
        return jsonify({
            'success': False,
            'error': 'is_occupied field required'
        }), 400

    if not isinstance(data['is_occupied'], bool):
        return jsonify({
            'success': False,
            'error': 'is_occupied must be a boolean'
        }), 400

    result = ParkingService.update_spot_occupancy(space_id, data['is_occupied'])

    if not result:
        return jsonify({
            'success': False,
            'error': 'Parking spot not found'
        }), 404

    return jsonify({
        'success': True,
        'data': result
    }), 200

@api_bp.route('/spots/<int:space_id>/history', methods=['GET'])
def get_spot_history(space_id):
    hours = request.args.get('hours', default=24, type=int)

    if hours < 1 or hours > 168:  
        return jsonify({
            'success': False,
            'error': 'Hours must be between 1 and 168'
        }), 400

    history = ParkingService.get_occupancy_history(space_id, hours)

    return jsonify({
        'success': True,
        'count': len(history),
        'data': history
    }), 200
