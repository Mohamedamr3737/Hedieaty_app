class Gift {
  String name;
  String category;
  String status;  // "Available", "Pledged", or "Delivered"
  bool isPledged;

  Gift({
    required this.name,
    required this.category,
    required this.status,
    this.isPledged = false,
  });
}
