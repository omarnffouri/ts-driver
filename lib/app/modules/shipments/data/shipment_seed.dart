import '../domain/entities/shipment_entity.dart';

/// When true, the shipments tabs are populated from in-memory seed data instead
/// of the API — so every shipment type/state can be inspected for design work
/// without backend round-trips. Flip to `false` to restore live data.
const bool kUseShipmentSeed = false;

/// Hand-built shipments covering each [TripType]/`driverStatus` the UI can show.
abstract final class ShipmentSeed {
  // ── New Load tab buckets ───────────────────────────────────────────────────

  static List<ShipmentEntity> assigned() => [
        _ship(
          id: 1001,
          number: 'SH-1001',
          status: 'assigned',
          amount: 2300,
          pickupInDays: 2,
          from: _loc(
            company: 'Atlas Freight Co.',
            address: '120 W 34th St',
            city: 'New York',
            state: 'NY',
            zip: '10001',
          ),
          to: _loc(
            company: 'Pacific Logistics',
            address: '800 S Hope St',
            city: 'Los Angeles',
            state: 'CA',
            zip: '90017',
          ),
        ),
        _ship(
          id: 1002,
          number: 'SH-1002',
          status: 'assigned',
          amount: 1850,
          extra: 150,
          pickupInDays: 4,
          from: _loc(
            company: 'Lakeside Distributors',
            address: '233 S Wacker Dr',
            city: 'Chicago',
            state: 'IL',
            zip: '60606',
          ),
          to: _loc(
            company: 'Gulf Coast Supply',
            address: '1500 McKinney St',
            city: 'Houston',
            state: 'TX',
            zip: '77010',
          ),
        ),
      ];

  static List<ShipmentEntity> waiting() => [
        _ship(
          id: 2001,
          number: 'SH-2001',
          status: 'waiting',
          amount: 3000,
          pickupInDays: 1,
          from: _loc(
            company: 'Bay Area Movers',
            address: '1 Market St',
            city: 'San Francisco',
            state: 'CA',
            zip: '94105',
          ),
          to: _loc(
            company: 'Cascade Warehousing',
            address: '400 Pine St',
            city: 'Seattle',
            state: 'WA',
            zip: '98101',
          ),
        ),
      ];

  static List<ShipmentEntity> transit() => [
        _ship(
          id: 3001,
          number: 'SH-3001',
          status: 'transit',
          amount: 4200,
          pickupInDays: 0,
          fromReached: true,
          from: _loc(
            company: 'Sunbelt Cargo',
            address: '2 N Central Ave',
            city: 'Phoenix',
            state: 'AZ',
            zip: '85004',
          ),
          to: _loc(
            company: 'Rocky Mountain Depot',
            address: '1701 California St',
            city: 'Denver',
            state: 'CO',
            zip: '80202',
          ),
        ),
      ];

  static List<ShipmentEntity> bolRejected() => [
        _ship(
          id: 4001,
          number: 'SH-4001',
          status: 'bol-rejected',
          amount: 2750,
          pickupInDays: -1,
          updatedDaysAgo: 1,
          from: _loc(
            company: 'Midwest Haulers',
            address: '600 Grant St',
            city: 'Pittsburgh',
            state: 'PA',
            zip: '15219',
          ),
          to: _loc(
            company: 'Liberty Freight',
            address: '30 S 15th St',
            city: 'Philadelphia',
            state: 'PA',
            zip: '19102',
          ),
        ),
      ];

  // ── Completed / Rejected (paginated) tabs ──────────────────────────────────

  static List<ShipmentEntity> completed() => [
        _ship(
          id: 5001,
          number: 'SH-5001',
          status: 'completed',
          amount: 3600,
          pickupInDays: -5,
          from: _loc(
            company: 'Northern Star Transit',
            address: '50 Fountain Plaza',
            city: 'Buffalo',
            state: 'NY',
            zip: '14202',
          ),
          to: _loc(
            company: 'Capital District Co.',
            address: '677 Broadway',
            city: 'Albany',
            state: 'NY',
            zip: '12207',
          ),
        ),
        _ship(
          id: 5002,
          number: 'SH-5002',
          status: 'transit-complete',
          amount: 4100,
          pickupInDays: -3,
          from: _loc(
            company: 'Delta Shipping',
            address: '201 St Charles Ave',
            city: 'New Orleans',
            state: 'LA',
            zip: '70170',
          ),
          to: _loc(
            company: 'Peachtree Logistics',
            address: '191 Peachtree St NE',
            city: 'Atlanta',
            state: 'GA',
            zip: '30303',
          ),
        ),
      ];

  static List<ShipmentEntity> rejected() => [
        _ship(
          id: 6001,
          number: 'SH-6001',
          status: 'rejected',
          amount: 1950,
          pickupInDays: -2,
          from: _loc(
            company: 'Harbor Point Freight',
            address: '100 Light St',
            city: 'Baltimore',
            state: 'MD',
            zip: '21202',
          ),
          to: _loc(
            company: 'Beltway Distribution',
            address: '1200 G St NW',
            city: 'Washington',
            state: 'DC',
            zip: '20005',
          ),
        ),
      ];

  // ── Builders ───────────────────────────────────────────────────────────────

  static ShipmentEntity _ship({
    required int id,
    required String number,
    required String status,
    required num amount,
    num? extra,
    required LocationEntity from,
    required LocationEntity to,
    int pickupInDays = 1,
    int? updatedDaysAgo,
    bool fromReached = false,
  }) {
    final now = DateTime.now();
    return ShipmentEntity(
      id: id,
      shipmentNumber: number,
      driverStatus: status,
      trailerId: 'TR-$id',
      driverId: '1',
      totalDrivers: '1',
      totalAmount: amount,
      additionalAmount: extra,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: updatedDaysAgo == null
          ? null
          : now.subtract(Duration(days: updatedDaysAgo)),
      estimatedDuration: '2 days',
      estimatedDistance: '1,240',
      driverInstruction: 'Deliver to dock 4. Call on arrival.',
      startLocation: LocEntity(
        stopType: 'pickup',
        goods: 'General freight',
        weight: '18,000 lbs',
        isReached: fromReached,
        location: from,
        transitDateTime: now.add(Duration(days: pickupInDays)),
      ),
      endLocation: LocEntity(
        stopType: 'dropoff',
        goods: 'General freight',
        weight: '18,000 lbs',
        isReached: false,
        location: to,
        transitDateTime: now.add(Duration(days: pickupInDays + 2)),
      ),
      shipmentStops: const [],
      isPreTripInspectionDone: false,
      isPostTripInspectionDone: false,
    );
  }

  static LocationEntity _loc({
    required String company,
    required String address,
    required String city,
    required String state,
    required String zip,
  }) {
    return LocationEntity(
      companyName: company,
      address: address,
      city: city,
      stateName: state,
      zipcode: zip,
      latitude: '0.0',
      longitude: '0.0',
    );
  }
}
