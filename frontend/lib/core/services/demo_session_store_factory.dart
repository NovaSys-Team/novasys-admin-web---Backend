import 'demo_session_store.dart';
import 'demo_session_store_memory.dart'
    if (dart.library.js_interop) 'demo_session_store_web.dart'
    as platform;

DemoSessionStore createDemoSessionStore() => platform.createDemoSessionStore();
