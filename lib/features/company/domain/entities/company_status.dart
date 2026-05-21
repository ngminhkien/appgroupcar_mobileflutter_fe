enum CompanyStatus {
  pending(0, 'Dang cho duyet'),
  approved(1, 'Da duyet'),
  rejected(2, 'Tu choi'),
  suspended(3, 'Tam ngung'),
  unknown(-1, 'Khong xac dinh');

  const CompanyStatus(this.apiValue, this.label);

  final int apiValue;
  final String label;

  static CompanyStatus fromApiValue(int? value) {
    switch (value) {
      case 0:
        return CompanyStatus.pending;
      case 1:
        return CompanyStatus.approved;
      case 2:
        return CompanyStatus.rejected;
      case 3:
        return CompanyStatus.suspended;
      default:
        return CompanyStatus.unknown;
    }
  }

  static CompanyStatus fromCompanyLoginApiValue(int? value) {
    switch (value) {
      case 1:
        return CompanyStatus.pending;
      case 2:
        return CompanyStatus.rejected;
      case 3:
        return CompanyStatus.suspended;
      case 4:
        return CompanyStatus.approved;
      case 0:
        return CompanyStatus.pending;
      default:
        return CompanyStatus.unknown;
    }
  }
}
