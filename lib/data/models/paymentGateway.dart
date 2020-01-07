class PaymentGeteway {
  final int? id;
  final String? paymentMethod;
  final String? apiKey;
  final String? secretKey;
  final String? currencyCode;
  final String? paymentLink;

  PaymentGeteway({
    this.id,
    this.paymentMethod,
    this.apiKey,
    this.secretKey,
    this.currencyCode,
    this.paymentLink,
  });

  PaymentGeteway copyWith({
    int? id,
    String? paymentMethod,
    String? apiKey,
    String? secretKey,
    String? currencyCode,
    String? paymentLink,
  }) {
    return PaymentGeteway(
      id: id ?? this.id,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      apiKey: apiKey ?? this.apiKey,
      secretKey: secretKey ?? this.secretKey,
      currencyCode: currencyCode ?? this.currencyCode,
      paymentLink: paymentLink ?? this.paymentLink,
    );
  }

  PaymentGeteway.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        paymentMethod = json['payment_method'] as String?,
        apiKey = json['api_key'] as String?,
        secretKey = json['secret_key'] as String?,
        currencyCode = json['currency_code'] as String?,
        paymentLink = json['payment_link'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'payment_method': paymentMethod,
        'api_key': apiKey,
        'secret_key': secretKey,
        'currency_code': currencyCode,
        'payment_link': paymentLink
      };
}
