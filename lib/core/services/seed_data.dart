import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';

class _SeedTarget {
  final String name;
  final int expectedAmount;
  final int givenAmount;
  const _SeedTarget(this.name, this.expectedAmount, this.givenAmount);
}

const _seeds = [
  _SeedTarget('Chikthayappa', 100000, 0),
  _SeedTarget('Somu Uncle', 30000, 0),
  _SeedTarget('Doctor', 30000, 0),
  _SeedTarget('Rahul Anna', 10000, 0),
  _SeedTarget('Manju Singh', 5000, 0),
  _SeedTarget('Anjan Reddy', 5000, 0),
  _SeedTarget('Left side of GRC enclave', 10000, 0),
  _SeedTarget('GRC enclave', 5000, 0),
  _SeedTarget('Neha Pride Apartment', 5000, 0),
  _SeedTarget('Nagbushan Reddy brother', 10000, 0),
  _SeedTarget('Chikthayappa 3 buildings', 5000, 0),
  _SeedTarget('Rahul Anna building', 5000, 0),
  _SeedTarget('Veeresh Anna', 10000, 0),
  _SeedTarget('Anil Anna', 5000, 0),
  _SeedTarget("Chintu's father", 5000, 0),
  _SeedTarget('Mahesh Anna', 2000, 0),
  _SeedTarget('Patil Anna', 3000, 0),
  _SeedTarget('Mysore aunty', 5000, 0),
  _SeedTarget('Rajappa', 3000, 0),
  _SeedTarget('Dhobhi Ghat', 10000, 0),
  _SeedTarget('Duplex 4th cross', 5000, 0),
  _SeedTarget('7th cross road', 10000, 0),
  _SeedTarget('Car godown', 5000, 0),
  _SeedTarget('Rajkumar', 2000, 0),
  _SeedTarget('Malli uncle', 2000, 0),
  _SeedTarget('Jyothi aunty building', 5000, 0),
  _SeedTarget('Manju Singh road', 5000, 0),
  _SeedTarget('Boda uncle', 2000, 0),
  _SeedTarget('Police and building', 3000, 0),
  _SeedTarget('Andra Avur building', 2000, 0),
  _SeedTarget('5th cross road buildings', 5000, 0),
  _SeedTarget('Sunitha aunty and building', 2000, 0),
  _SeedTarget('Driver uncle', 2000, 0),
  _SeedTarget('A1 Travels', 5000, 0),
  _SeedTarget('Jayanthi aunty', 2000, 0),
  _SeedTarget('Gupta Anna', 3000, 0),
  _SeedTarget('GRC enclave road', 10000, 0),
  _SeedTarget('Rajesha building', 5000, 0),
  _SeedTarget('Lokesh and building', 5000, 0),
  _SeedTarget('Shekar Anna and courier', 3000, 0),
  _SeedTarget('4th cross road', 10000, 0),
  _SeedTarget('3rd cross road and gym', 5000, 0),
  _SeedTarget('Shops', 3000, 0),
  _SeedTarget('Other', 3000, 0),
];

Future<int> seedTargets(FirestoreService service) async {
  if (await service.targetsExist(AppConstants.festivalId)) {
    debugPrint('[SEED] Targets already exist — skipping seed');
    return 0;
  }

  final now = Timestamp.now();
  var count = 0;
  for (final s in _seeds) {
    final target = Target(
      id: service.generateId(),
      festivalId: AppConstants.festivalId,
      name: s.name,
      expectedAmount: s.expectedAmount,
      givenAmount: s.givenAmount,
      createdAt: now,
      updatedAt: now,
    );
    await service.addTarget(target);
    count++;
  }
  debugPrint('[SEED] Inserted $count targets');
  return count;
}
