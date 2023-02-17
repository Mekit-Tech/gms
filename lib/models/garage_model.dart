
class Garage {
  final int id;
  final String name;
  final String phoneNumber;
  final String location;
  final String imageUrl;

  const Garage(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.location,
      required this.imageUrl});

  @override
  List<Object> get props => [id, name, phoneNumber, location, imageUrl];

  @override
  bool get stringify => true;
}

Garage joel = const Garage(
  id: 1,
  name: "Express Autocare",
  phoneNumber: "+91 8888657702",
  location: "Gawdrage Hills",
  imageUrl: "https://mekit.in/assets/logos/expressautocare.png",
);

Garage sardar = const Garage(
  id: 2,
  name: "Wash and More",
  phoneNumber: "+91 8888657702",
  location: "Near Sandeep Hotel",
  imageUrl: "https://mekit.in/assets/logos/washandmore.png",
);

Garage mannu = const Garage(
  id: 3,
  name: "Mannu Auto",
  phoneNumber: "+91 8888657702",
  location: "Near New Road",
  imageUrl: "https://mekit.in/assets/logos/mannuauto.png",
);

// Above data will be used like this to the pdf generator 
// garage.id
// garage.name 
// garage.phoneNumber
// garage.location
// garage.imageUrl
