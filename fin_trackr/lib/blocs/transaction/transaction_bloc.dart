import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../models/transaction_model.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final Box<TransactionModel> _box = Hive.box<TransactionModel>('transactions');

  TransactionBloc() : super(TransactionLoading()) {
    on<LoadTransactions>((event, emit) {
      final all = _box.values.toList();
      emit(TransactionLoaded(transactions: all));
    });

    on<AddTransaction>((event, emit) async {
      await _box.put(event.transaction.id, event.transaction);
      emit(TransactionLoaded(transactions: _box.values.toList()));
    });

    on<DeleteTransaction>((event, emit) async {
      await _box.delete(event.id);
      emit(TransactionLoaded(transactions: _box.values.toList()));
    });

    on<FilterTransactions>((event, emit) {
      try {
        final all = _box.values.toList();

        final filtered =
            all.where((tx) {
              // Safe date check
              // ignore: unnecessary_null_comparison, unnecessary_type_check
              final dateValid = tx.date != null && tx.date is DateTime;

              final dateOk =
                  event.range == null ||
                  (dateValid &&
                      !tx.date.isBefore(event.range!.start) &&
                      !tx.date.isAfter(event.range!.end));

              // Safe category check
              final catValid =
                  // ignore: unnecessary_null_comparison
                  tx.category != null && tx.category.trim().isNotEmpty;

              final categoryOk =
                  event.category == null ||
                  event.category!.trim().isEmpty ||
                  (catValid &&
                      tx.category.toLowerCase() ==
                          event.category!.toLowerCase());

              return dateOk && categoryOk;
            }).toList();

        emit(TransactionLoaded(transactions: filtered));
      } catch (e, stacktrace) {
        print("=== FilterTransactions Exception ===");
        print(e);
        print(stacktrace);
        emit(TransactionLoaded(transactions: []));
      }
    });
  }
}
