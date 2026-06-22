import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_super_app/features/profile/domain/user_model.dart';
import 'package:vehicle_super_app/features/vehicle_tracker/domain/vehicle_model.dart';

void main() {
  group('Ecosystem Data Models Unit Tests', () {
    test('UserModel serialization and copyWith works', () {
      const user = UserModel(
        id: 'u-100',
        name: 'Alex Pierce',
        email: 'alex@example.com',
        memberTier: 'Gold Elite',
      );

      // copyWith
      final updatedUser = user.copyWith(name: 'Alexander Pierce');
      expect(updatedUser.name, 'Alexander Pierce');
      expect(updatedUser.id, 'u-100');

      // toJson
      final json = user.toJson();
      expect(json['id'], 'u-100');
      expect(json['name'], 'Alex Pierce');

      // fromJson
      final userFromJson = UserModel.fromJson(json);
      expect(userFromJson.name, 'Alex Pierce');
      expect(userFromJson.memberTier, 'Gold Elite');
    });

    test('VehicleModel serialization and copyWith works', () {
      const vehicle = VehicleModel(
        id: 'v-200',
        name: 'My Model 3',
        model: 'Tesla Model 3',
        plateNumber: 'SF-8820-CA',
        latitude: 37.7749,
        longitude: -122.4194,
        fuelLevel: 88.5,
        status: 'Parked',
      );

      // copyWith
      final updatedVehicle = vehicle.copyWith(status: 'Driving', fuelLevel: 87.0);
      expect(updatedVehicle.status, 'Driving');
      expect(updatedVehicle.fuelLevel, 87.0);
      expect(updatedVehicle.plateNumber, 'SF-8820-CA');

      // toJson
      final json = vehicle.toJson();
      expect(json['plateNumber'], 'SF-8820-CA');
      expect(json['latitude'], 37.7749);

      // fromJson
      final vehicleFromJson = VehicleModel.fromJson(json);
      expect(vehicleFromJson.model, 'Tesla Model 3');
      expect(vehicleFromJson.fuelLevel, 88.5);
    });
  });
}
