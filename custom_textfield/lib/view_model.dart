import 'dart:async';

class TextFieldViewModel {
  final _controllerHasValueSubject = StreamController<bool>();
  StreamSink<bool> get _controllerHasValueSink =>
      _controllerHasValueSubject.sink;
  Stream<bool> get controllerHasValueStream =>
      _controllerHasValueSubject.stream;

  void changedHasValue(bool val) => _controllerHasValueSink.add(val);

  void disposeStream() {
    _controllerHasValueSubject.close();
  }
}
