import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/run_model.dart';

final selectedRunProvider = StateProvider<Run?>((ref) => null);
final completedRunsProvider = StateProvider<List<int>?>((ref) => []);
final runPlayMapButtonProvider = StateProvider<Map<int, bool>>((ref) => <int, bool>{});