import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/client_firms_repository.dart';
import '../data/models/client_firm.dart';
import 'database_providers.dart';

// ClientFirmsDao provider
final clientFirmsDaoProvider = Provider<ClientFirmsDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final idService = ref.watch(globalIdServiceProvider);
  return ClientFirmsDao(database, idService);
});

// All client firms provider
final clientFirmsProvider = FutureProvider<List<ClientFirm>>((ref) async {
  final dao = ref.watch(clientFirmsDaoProvider);
  return await dao.getAllClientFirms();
});

// Selected client firm ID provider (for forms)
final selectedClientFirmIdProvider = StateProvider<int?>((ref) => null);

// Bills filter client firm ID provider (persists filter selection on Bills Management screen)
final billsFilterClientFirmIdProvider = StateProvider<int?>((ref) => null);
