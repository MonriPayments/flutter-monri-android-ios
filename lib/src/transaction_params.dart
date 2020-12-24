import 'package:MonriPayments/src/customer_params.dart';

class TransactionParams {
  Map<String, String> data = {};

  static TransactionParams create() => TransactionParams();

  TransactionParams set(String key, String value) {
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
    return this;
  }

  TransactionParams setFromCustomerParams(CustomerParams customerParams) => customerParams == null
      ? this
      : set("ch_full_name", customerParams.fullName)
          .set("ch_address", customerParams.address)
          .set("ch_city", customerParams.city)
          .set("ch_zip", customerParams.zip)
          .set("ch_phone", customerParams.phone)
          .set("ch_country", customerParams.country)
          .set("ch_email", customerParams.email);

  Map<String, dynamic> toJson() => data;
}
