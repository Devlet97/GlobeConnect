class Country {
  final String name;
  final String flag;
  bool isSelected;

  Country({
    required this.name,
    required this.flag,
    this.isSelected = false,
  });
}
