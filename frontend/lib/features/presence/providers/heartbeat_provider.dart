import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'team_pulse_provider.dart';

/// Manages the 5-second heartbeat while the app is foregrounded, and
/// calls setOffline when the app is backgrounded/closed. Instantiate
/// once, high in the widget tree (e.g. wrapping the authenticated
/// shell), via HeartbeatController.start()/stop() tied to
/// WidgetsBindingObserver lifecycle events.
class HeartbeatService {
  final Ref _ref;
  Timer? _timer;

  HeartbeatService(this._ref);

  void start() {
    _timer?.cancel();
    // Fire once immediately, then every 5s.
    _sendHeartbeat();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _sendHeartbeat());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendHeartbeat() async {
    final repository = _ref.read(presenceRepositoryProvider);
    await repository.sendHeartbeat();
  }

  Future<void> markOffline() async {
    stop();
    final repository = _ref.read(presenceRepositoryProvider);
    await repository.setOffline();
  }
}

final heartbeatServiceProvider = Provider<HeartbeatService>((ref) {
  final service = HeartbeatService(ref);
  ref.onDispose(() => service.stop());
  return service;
});

/// Wrap the authenticated part of the app with this widget (e.g. inside
/// the ShellRoute's builder in app_router.dart) so the heartbeat starts
/// once login succeeds and stops cleanly on logout/app close, and reacts
/// to the app being backgrounded vs foregrounded.
class HeartbeatLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  const HeartbeatLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<HeartbeatLifecycleObserver> createState() => _HeartbeatLifecycleObserverState();
}

class _HeartbeatLifecycleObserverState extends ConsumerState<HeartbeatLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(heartbeatServiceProvider).start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(heartbeatServiceProvider).stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final service = ref.read(heartbeatServiceProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        service.start();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        service.markOffline();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break; // transient states, don't act
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}