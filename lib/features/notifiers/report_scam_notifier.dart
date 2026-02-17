import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/api_response.dart';
import 'package:valarpay/features/repositories/report_scam_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

class ReportScamNotifier extends StateNotifier<DataState<ApiResponse>> {
  final ReportScamRepository _repository;

  ReportScamNotifier(this._repository) : super(DataState<ApiResponse>.initial());

  Future<void> report({required String title, required String description, File? screenshot}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.submitReport(title: title, description: description, screenshot: screenshot);
      state = state.copyWith(isInitialLoading: false, isDataAvailable: true, data: [res], message: res.message);
    } catch (e, stack) {
      log('[ReportScamNotifier] error: $e\n$stack');
      state = state.copyWith(isInitialLoading: false, isDataAvailable: false, message: e.toString());
    }
  }

  void reset() => state = DataState<ApiResponse>.initial();
}

final reportScamRepositoryProvider = Provider<ReportScamRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return ReportScamRepository(api);
});

final reportScamNotifierProvider = StateNotifierProvider<ReportScamNotifier, DataState<ApiResponse>>((ref) {
  final repo = ref.read(reportScamRepositoryProvider);
  return ReportScamNotifier(repo);
});
