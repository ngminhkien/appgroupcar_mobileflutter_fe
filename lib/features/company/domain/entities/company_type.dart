enum CompanyType {
  bus(1, 'Nha xe'),
  carRental(2, 'Cho thue xe'),
  rideSharing(3, 'Xe cong nghe');

  const CompanyType(this.apiValue, this.label);

  final int apiValue;
  final String label;

  static CompanyType fromApiValue(int? value) {
    switch (value) {
      case 1:
        return CompanyType.bus;
      case 2:
        return CompanyType.carRental;
      case 3:
        return CompanyType.rideSharing;
      default:
        return CompanyType.bus;
    }
  }
}
