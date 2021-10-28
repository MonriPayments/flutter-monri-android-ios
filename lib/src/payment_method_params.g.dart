// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodParams _$PaymentMethodParamsFromJson(Map<String, dynamic> json) =>
    PaymentMethodParams(
      json['type'] as String,
      Map<String, String>.from(json['data'] as Map),
    );

Map<String, dynamic> _$PaymentMethodParamsToJson(
        PaymentMethodParams instance) =>
    <String, dynamic>{
      'type': instance.type,
      'data': instance.data,
    };
