import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/nav_bar_provider.g.dart';
@Riverpod(keepAlive: true)
class NavBar extends _$NavBar {
	@override
  bool build() {
    return true;
  }

  disable() {
    state = false;
  }

  enable() {
    state = true;
  }
}
