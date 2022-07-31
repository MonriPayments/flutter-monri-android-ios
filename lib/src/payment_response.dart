class PaymentResponse{
  final PaymentResponseStatus status;
  final Map<String, dynamic> data;


  PaymentResponse(this.status, this.data);

  factory PaymentResponse.fromJson(Map json){
    print(json);
    String statusString = json["status"] ?? "unknown";
    if(statusString == "result"){
      statusString = json["data"]["status"];
    }

    PaymentResponseStatus status;
    Map<String, dynamic> data =
        json.containsKey("data") ? Map<String, dynamic>.from(json["data"]) : {};

    switch (statusString) {
      case "approved" :
        status = PaymentResponseStatus.approved;
        break;
      case "declined" :
        status = PaymentResponseStatus.declined;
        break;
      case "error" :
        status = PaymentResponseStatus.error;
        break;
      default:
        status = PaymentResponseStatus.unknown;
    }

    return PaymentResponse(status, data);

  }

  Map<String, dynamic> toJson() => {
    "status" : status.toString(),
    "data": data
  };

  @override
  String toString() => 'PaymentResponse{status: $status}';
}

enum PaymentResponseStatus{
  approved, declined, error, unknown,
}
