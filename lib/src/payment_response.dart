class PaymentResponse{
  final PaymentResponseStatus status;


  PaymentResponse(this.status);

  factory PaymentResponse.fromJson(Map json){
    print(json);
    String statusString = json["status"] ?? "unknown";
    if(statusString == "result"){
      statusString = json["data"]["status"];
    }

    PaymentResponseStatus status;

    switch(statusString){
      case "approved" : status = PaymentResponseStatus.approved;break;
      case "declined" : status = PaymentResponseStatus.declined;break;
      case "error" : status = PaymentResponseStatus.error;break;
      default: status = PaymentResponseStatus.unknown;
    }

    return PaymentResponse(status);

  }

  Map<String, dynamic> toJson() => {
    "status" : status.toString(),
  };

  @override
  String toString() => 'PaymentResponse{status: $status}';
}

enum PaymentResponseStatus{
  approved, declined, error, unknown,
}
