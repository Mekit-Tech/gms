class GarageModel {
  final String name;
  final String address;
  final String phoneNumber;
  final String garageLogo;
  final String createdAt;
  final String uid;

  GarageModel({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.garageLogo,
    required this.createdAt,
    required this.uid,
  });

  // from map - we get the data from the server

  factory GarageModel.fromMap(Map<String, dynamic> map) {
    return GarageModel(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      garageLogo: map['garageLogo'] ?? '',
      createdAt: map['createdAt'] ?? '',
      uid: map['uid'] ?? '',
    );
  }

  // to map - we sending data to the server
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "address": address,
      "phoneNumber": phoneNumber,
      "garageLogo": garageLogo,
      "createdAt": createdAt,
      "uid": uid,
    };
  }
}
