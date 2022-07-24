import 'package:hyper_customer/app/data/models/auth_model.dart';
import 'package:hyper_customer/app/data/models/rent_stations_model.dart';

abstract class Repository {
  Future<String> verify(String phoneNumber);
  Future<Auth> login(String phoneNumber, String password);

  Future<String> deposit(double amount, int method, String customerId);
  Future<bool> checkDeposit(String id);

  Future<double> getBalance(String customerId);

  Future<bool> cardLink(String customerId, String uid);

  Future<RentStations> getRentStations();
}
