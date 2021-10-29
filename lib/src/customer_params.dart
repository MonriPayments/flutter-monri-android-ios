import 'package:json_annotation/json_annotation.dart';
part 'customer_params.g.dart';

@JsonSerializable()
class CustomerParams{
  @JsonKey(name : "email")
  String? email;
  @JsonKey(name : "full_name")
  String? fullName;
  @JsonKey(name : "address")
  String? address;
  @JsonKey(name : "city")
  String? city;
  @JsonKey(name : "zip")
  String? zip;
  @JsonKey(name : "phone")
  String? phone;
  @JsonKey(name : "country")
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
