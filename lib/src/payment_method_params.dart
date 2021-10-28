import 'package:json_annotation/json_annotation.dart';
part 'payment_method_params.g.dart';

@JsonSerializable()
class PaymentMethodParams{
  String type;
  Map<String, String> data;

  PaymentMethodParams(this.type, this.data);

  factory PaymentMethodParams.fromJson(Map<String, dynamic> json) => _$PaymentMethodParamsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodParamsToJson(this);
}
