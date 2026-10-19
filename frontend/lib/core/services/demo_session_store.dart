/// Persists only a public demo-session marker, never account credentials.
abstract interface class DemoSessionStore {
  bool get hasSession;
  void save({required bool persistent});
  void clear();
}

class MemoryDemoSessionStore implements DemoSessionStore {
  MemoryDemoSessionStore({this._active = false});
  bool _active;
  bool persistent = false;
  @override
  bool get hasSession => _active;
  @override
  void save({required bool persistent}) {
    this.persistent = persistent;
    _active = true;
  }

  @override
  void clear() {
    _active = false;
    persistent = false;
  }
}
