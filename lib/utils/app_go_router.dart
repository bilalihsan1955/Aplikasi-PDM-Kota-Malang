import 'package:go_router/go_router.dart';

GoRouter? _boundRouter;

void bindAppGoRouter(GoRouter router) {
  _boundRouter = router;
}

void unbindAppGoRouter() {
  _boundRouter = null;
}

GoRouter? get appGoRouterOrNull => _boundRouter;
