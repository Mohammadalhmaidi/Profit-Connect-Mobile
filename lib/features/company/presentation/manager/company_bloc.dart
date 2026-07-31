import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/usecases/create_company_usecase.dart';

part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CreateCompanyUseCase createCompanyUseCase;

  CompanyBloc({required this.createCompanyUseCase})
      : super(CompanyInitial()) {
    on<CreateCompanyEvent>(_onCreateCompany);
    on<ResetCompanyEvent>((event, emit) => emit(CompanyInitial()));
  }

  Future<void> _onCreateCompany(
    CreateCompanyEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyLoading());
    final result = await createCompanyUseCase(CreateCompanyParams(
      name: event.name,
      description: event.description,
      industry: event.industry,
      website: event.website,
      location: event.location,
      logo: event.logo,
    ));
    result.fold(
      (failure) => emit(CompanyError(failure.message)),
      (company) => emit(CompanyCreated(company)),
    );
  }
}
