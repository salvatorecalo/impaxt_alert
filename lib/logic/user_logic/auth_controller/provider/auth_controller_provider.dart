import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/user_logic/auth_controller/auth_controller.dart';

final authControllerProvider = Provider((ref) => AuthController());