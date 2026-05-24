import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming_example/calling_page.dart';
import 'package:flutter_callkit_incoming_example/home_page.dart';
import 'package:flutter_callkit_incoming_example/incoming_call_header.dart';

class AppRoute {
  static const homePage = '/home_page';

  static const callingPage = '/calling_page';
  static const incomingCallHeader = '/incoming_call_header';

  static Route<Object>? generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';
    final uri = Uri.tryParse(routeName);
    final path = uri?.path ?? routeName;

    switch (path) {
      case '/':
      case homePage:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case callingPage:
        return MaterialPageRoute(
          builder: (_) => const CallingPage(),
          settings: settings,
        );
      case incomingCallHeader:
        return MaterialPageRoute(
          builder: (_) =>
              IncomingCallHeader(uri: uri ?? Uri(path: incomingCallHeader)),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
