
class PaymentMethodParams{
  String type;
  Map<String, String> data;

  PaymentMethodParams(this.type, this.data);

  factory PaymentMethodParams.fromJson(Map<String, dynamic> json) {
    return PaymentMethodParams(
      json['type'] as String,
      Map<String, String>.from(json['data'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
}