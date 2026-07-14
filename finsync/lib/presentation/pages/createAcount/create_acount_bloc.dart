import 'package:finsync/presentation/pages/createAcount/create_acount_event.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAcountBloc extends Bloc<CreateAcountEvent, CreateAcountState> {
  CreateAcountBloc() : super(CreateAcountInitialState());
}
