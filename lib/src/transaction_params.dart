import 'package:MonriPayments/src/customer_params.dart';

class TransactionParams {
  Map<String, String> data = {};

  static TransactionParams create() => TransactionParams();

  TransactionParams set(String key, String? value) {
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
    return this;
  }

  TransactionParams setFromCustomerParams(CustomerParams customerParams) =>
           set("full_name", customerParams.full_name)
          .set("address", customerParams.address)
          .set("city", customerParams.city)
          .set("zip", customerParams.zip)
          .set("phone", customerParams.phone)
          .set("country", customerParams.country)
          .set("email", customerParams.email);

  Map<String, dynamic> toJson() => data;
}
