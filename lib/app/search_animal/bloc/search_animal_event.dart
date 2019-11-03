import 'package:animal_repository/animal_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class SearchAnimalEvent extends Equatable {
  const SearchAnimalEvent();
}

class QueryChanged extends SearchAnimalEvent {
  final String query;

  const QueryChanged({@required this.query});

  @override
  List<Object> get props => [query];

  @override
  String toString() => 'QueryChanged { query: $query }';
}

class ResultsUpdated extends SearchAnimalEvent {
  final List<AnimalSearchResult> results;

  const ResultsUpdated({@required this.results});

  @override
  List<Object> get props => [results];

  String toString() => 'ResultsUpdated { results: $results }';
}