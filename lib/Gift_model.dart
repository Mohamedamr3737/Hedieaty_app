class Gift {
  String name;
  String category;
  String status;  // "Available", "Pledged", or "Delivered"
  bool isPledged;
  double price;
  String? imagePath;  // Path to the image file

  Gift({
    required this.name,
    required this.category,
    required this.status,
    required this.price,
    this.isPledged = false,
    this.imagePath,
  });
}
