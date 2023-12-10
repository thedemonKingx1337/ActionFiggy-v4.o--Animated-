import 'package:flutter/material.dart';

class CustomRouteAnimations<T> extends MaterialPageRoute<T> {
  CustomRouteAnimations({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (ModalRoute.of(context)!.isFirst) {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionAnimation extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (ModalRoute.of(context)!.isFirst) {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
