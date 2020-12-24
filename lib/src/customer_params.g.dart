// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerParams _$CustomerParamsFromJson(Map<String, dynamic> json) {
  return CustomerParams()
    ..email = json['email'] as String
    ..fullName = json['ch_full_name'] as String
    ..address = json['ch_address'] as String
    ..city = json['ch_city'] as String
    ..zip = json['ch_zip'] as String
    ..phone = json['ch_phone'] as String
    ..country = json['ch_country'] as String;
}

Map<String, dynamic> _$CustomerParamsToJson(CustomerParams instance) =>
    <String, dynamic>{
      'email': instance.email,
      'ch_full_name': instance.fullName,
      'ch_address': instance.address,
      'ch_city': instance.city,
      'ch_zip': instance.zip,
      'ch_phone': instance.phone,
      'ch_country': instance.country,
    };
