import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/delivery_model.dart';

final currentDeliveryProvider = StateProvider<Delivery?>((ref) => null);
final currentDeliveryIsCompletedProvider = StateProvider<bool>((ref) => false);
final allDeliveriesCompleteProvider = StateProvider<bool>((ref) => false);
