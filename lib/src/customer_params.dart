import 'package:json_annotation/json_annotation.dart';
part 'customer_params.g.dart';

@JsonSerializable()
class CustomerParams{
  @JsonKey(name : "email")
  String? email;
  @JsonKey(name : "ch_full_name")
  String? fullName;
  @JsonKey(name : "ch_address")
  String? address;
  @JsonKey(name : "ch_city")
  String? city;
  @JsonKey(name : "ch_zip")
  String? zip;
  @JsonKey(name : "ch_phone")
  String? phone;
  @JsonKey(name : "ch_country")
  String? country;

  CustomerParams({
       this.email,
       this.fullName,
       this.address,
       this.city,
       this.zip,
       this.phone,
       this.country
      });

  // CustomerParams.init(this.email, this.fullName, this.address, this.city, this.zip, this.phone, this.country);

  factory CustomerParams.fromJson(Map<String, dynamic> json) => _$CustomerParamsFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerParamsToJson(this);
}
