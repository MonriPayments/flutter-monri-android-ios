// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodParams _$PaymentMethodParamsFromJson(Map<String, dynamic> json) {
  return PaymentMethodParams()
    ..type = json['type'] as String
    ..data = (json['data'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    );
}

Map<String, dynamic> _$PaymentMethodParamsToJson(
        PaymentMethodParams instance) =>
    <String, dynamic>{
      'type': instance.type,
      'data': instance.data,
    };
