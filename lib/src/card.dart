
import 'package:MonriPayments/src/payment_method.dart';

class Card extends PaymentMethod{
  String number;
  String cvc;
  int expMonth;
  int expYear;
  bool tokenizePan;


  Card(this.number, this.cvc, this.expMonth, this.expYear, this.tokenizePan);

  @override
  String paymentMethodType() => PaymentMethod.TYPE_CARD;

  @override
  Map<String, String> data() {
    var data = Map<String, String>();
    data["pan"] = number;
    data["expiration_date"] = "$expYear$expMonth";
    data["cvv"] = cvc;
    data["tokenize_pan"] = "$tokenizePan";
    return data;
  }
}
