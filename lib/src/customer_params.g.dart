// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerParams _$CustomerParamsFromJson(Map<String, dynamic> json) =>
    CustomerParams(
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      zip: json['zip'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$CustomerParamsToJson(CustomerParams instance) =>
    <String, dynamic>{
      'email': instance.email,
      'full_name': instance.fullName,
      'address': instance.address,
      'city': instance.city,
      'zip': instance.zip,
      'phone': instance.phone,
      'country': instance.country,
    };
