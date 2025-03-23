class Item {
  final int itemId;
  final String itemname;
  final String itemdescription;
  final double itemvalue;
  final String itemimage;

  Item({
    required this.itemId,
    required this.itemname,
    required this.itemdescription,
    required this.itemvalue,
    required this.itemimage,
  });

  // Convert JSON to Item object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'],
      itemname: json['itemname'],
      itemdescription: json['itemdescription'] ?? '',
      itemvalue: (json['itemvalue'] ?? 0).toDouble(),
      itemimage: json['itemimage'] ?? '',  // Handle null image case
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "itemname": itemname,
      "itemdescription": itemdescription,
      "itemvalue": itemvalue,
      "itemimage": itemimage,
    };
  }
}
