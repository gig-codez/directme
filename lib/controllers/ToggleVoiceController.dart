import 'package:flutter_bloc/flutter_bloc.dart';

class ToggleVoiceController extends Cubit<bool>{
  ToggleVoiceController() : super(false);

  void toggleVoice(){
    emit(!state);
  }
}