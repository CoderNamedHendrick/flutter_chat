class UserDescriptor {
  final String userName;
  final String password;

  const UserDescriptor({required this.userName, required this.password});

  factory UserDescriptor.fromJson(Map<String, dynamic> json) =>
      UserDescriptor(userName: json['userName'], password: json['password']);

  Map<String, dynamic> toJson() => {'userName': userName, 'password': password};
}
