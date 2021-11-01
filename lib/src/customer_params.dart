
class CustomerParams{
  String? email;
  String? full_name;
  String? address;
  String? city;
  String? zip;
  String? phone;
  String? country;

  CustomerParams({
       this.email,
       this.full_name,
       this.address,
       this.city,
       this.zip,
       this.phone,
       this.country
      });


  factory CustomerParams.fromJson(Map<String, dynamic> json) {
    return CustomerParams(
      email: json['email'] as String,
      full_name: json['full_name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      zip: json['zip'] as String,
      phone: json['phone'] as String,
      country: json['country'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': full_name,
      'address': address,
      'city': city,
      'zip': zip,
      'phone': phone,
      'country': country
    };
  }
}
