import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple toggle for metrics HUD visibility
final metricsVisibilityProvider = StateProvider<bool>((ref) => false);
