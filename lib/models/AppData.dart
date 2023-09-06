
import 'User.dart';

class AppData {
  static const int BUILD_VERSION = 200;
  static String supportedPayments = '';

  int minBuildVersion;
  String paymentMethod;

  User? user;

  AppData(this.minBuildVersion, this.paymentMethod, this.user);

  static AppData fromJson(Map<String, dynamic> jsonObject) {
    Map<String, dynamic> appDataObject = jsonObject['appdata'];

    int minBuildVersion =
        int.parse(appDataObject['application_minimum_version'].toString());
    String supportPayments = appDataObject['support_payments'].toString();
    supportedPayments = supportPayments;

    User? user;
    if (jsonObject['user'] != null) {
      user = User.fromJson(jsonObject['user']);
    }

    return AppData(minBuildVersion, supportPayments, user);
  }

  bool isAppUpdated() {
    return BUILD_VERSION >= minBuildVersion;
  }

  @override
  String toString() {
    return 'AppData{BUILD_VERSION: $BUILD_VERSION, minBuildVersion: $minBuildVersion, user: $user}';
  }

  static paymentMethodEnabled(int paymentMethod) {
    return supportedPayments.split(',').contains(paymentMethod.toString());
  }
}