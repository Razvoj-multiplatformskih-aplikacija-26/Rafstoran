import 'package:bloc/bloc.dart';

final class ConsoleBlocObserver extends BlocObserver {
  const ConsoleBlocObserver(this.log);

  final void Function(String line) log;

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    log('${bloc.runtimeType} · ${transition.event.runtimeType} → ${transition.nextState}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('${bloc.runtimeType} · error: $error');
  }
}
