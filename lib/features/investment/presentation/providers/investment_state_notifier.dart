// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';
// import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
// import '../../data/models/investment_scheme.dart';
// import '../../data/repositories/investment_repository.dart';
//
// // Notifier for investment schemes
// class InvestmentSchemesNotifier extends Notifier<InvestmentSchemesState> {
//   bool _hasLoadedOnce = false;
//
//   @override
//   InvestmentSchemesState build() {
//     // Load data immediately when notifier is created
//     Future.microtask(() => loadSchemes());
//     return InvestmentSchemesState();
//   }
//
//   Future<void> loadSchemes() async {
//     // Prevent multiple simultaneous calls
//     if (state.isLoading || _hasLoadedOnce) return;
//
//     state = state.copyWith(isLoading: true, error: null);
//
//     try {
//       final repository = ref.read(investmentRepositoryProvider);
//       final schemes = await repository.getAllSchemes();
//
//       state = state.copyWith(
//         schemes: schemes,
//         isLoading: false,
//       );
//
//       _hasLoadedOnce = true;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }
//
//   Future<void> refresh() async {
//     _hasLoadedOnce = false;
//     state = InvestmentSchemesState();
//     await loadSchemes();
//   }
// }
