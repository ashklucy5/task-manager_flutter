import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../presence/providers/team_pulse_provider.dart';
import '../data/team_repository.dart';

final teamRepositoryProvider = Provider((ref) => TeamRepository(ref.watch(dioProvider)));

/// team_list_screen reuses teamPulseProvider's grouping directly — same
/// data, same role-based scoping, no need to refetch separately.
final teamListProvider = teamPulseProvider;