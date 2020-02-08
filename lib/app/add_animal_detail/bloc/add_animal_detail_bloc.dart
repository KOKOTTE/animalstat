import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:livestock_repository/livestock_repository.dart';
import 'package:meta/meta.dart';
import './bloc.dart';

class AddAnimalDetailBloc
    extends Bloc<AddAnimalDetailEvent, AddAnimalDetailState> {
  final int _animalNumber;
  final AnimalRepository _animalRepository;

  AddAnimalDetailBloc({
    @required int animalNumber,
    @required AnimalRepository animalRepository,
  })  : assert(animalNumber != null),
        assert(animalRepository != null),
        _animalNumber = animalNumber,
        _animalRepository = animalRepository;

  @override
  AddAnimalDetailState get initialState =>
      AddAnimalDetailState.initial(_animalNumber);

  @override
  Stream<AddAnimalDetailState> mapEventToState(
    AddAnimalDetailEvent event,
  ) async* {
    if (event is UpdateDiagnosis) {
      yield* _updateDiagnoses(event);
    } else if (event is UpdateHealthStatus) {
      yield* _updateHealthStatus(event);
    } else if (event is UpdateTreatment) {
      yield* _updateTreatment(event);
    } else if (event is SaveAnimalHistoryRecord) {
      yield* _saveAnimalHistoryRecord(event);
    }
  }

  Stream<AddAnimalDetailState> _saveAnimalHistoryRecord(
      SaveAnimalHistoryRecord event) async* {
    await _animalRepository.insertHistoryRecord(
      event.stateToSave.animalNumber,
      event.stateToSave.toModel(),
    );

    yield state.copyWith(isSaved: true);
  }

  Stream<AddAnimalDetailState> _updateDiagnoses(
    UpdateDiagnosis event,
  ) async* {
    final diagnosis = event.diagnosis == event.previousState.diagnosis
        ? Diagnoses.none
        : event.diagnosis;
    final treatment = !allowTreatmentSelection(
      event.previousState.healthStatus,
      diagnosis,
    )
        ? Treatments.none
        : null;

    yield event.previousState.copyWith(
      diagnosis: diagnosis,
      treatment: treatment,
    );
  }

  Stream<AddAnimalDetailState> _updateHealthStatus(
    UpdateHealthStatus event,
  ) async* {
    final healthStatus = event.healthStatus == event.previousState.healthStatus
        ? HealthStates.unknown
        : event.healthStatus;
    final diagnosis =
        !allowDiagnosisSelection(healthStatus) ? Diagnoses.none : null;
    final treatment = !allowTreatmentSelection(healthStatus, diagnosis)
        ? Treatments.none
        : null;

    yield event.previousState.copyWith(
      diagnosis: diagnosis,
      healthStatus: healthStatus,
      treatment: treatment,
    );
  }

  Stream<AddAnimalDetailState> _updateTreatment(
    UpdateTreatment event,
  ) async* {
    final treatment = event.treatment == event.previousState.treatment
        ? Treatments.none
        : event.treatment;

    yield event.previousState.copyWith(treatment: treatment);
  }

  static bool allowDiagnosisSelection(HealthStates healthStatus) =>
      healthStatus == HealthStates.ill ||
      healthStatus == HealthStates.suspicious;
  static bool allowTreatmentSelection(
          HealthStates healthStatus, Diagnoses diagnosis) =>
      AddAnimalDetailBloc.allowDiagnosisSelection(healthStatus) &&
      diagnosis != Diagnoses.none;
}
