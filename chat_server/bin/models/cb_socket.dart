class SocketCallbackModel {
  final String message;
  final Map<String, dynamic>? data;

  SocketCallbackModel({required this.message, this.data});

  factory SocketCallbackModel.fromJson(Map<String, dynamic> json) =>
      SocketCallbackModel(message: json['message'], data: json['data']);

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data,
      };
}
