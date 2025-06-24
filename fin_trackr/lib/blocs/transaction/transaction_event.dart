import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterTransactions extends TransactionEvent {
  final DateTimeRange? range;
  final String? category;

  const FilterTransactions({this.range, this.category});

  @override
  List<Object?> get props => [range, category];
}
