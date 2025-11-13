class Company {
  final String name;
  final String address;
  final String website;
  final String ceo;
  final String iban;
  final String bic;

  Company({
    required this.name,
    required this.address,
    required this.website,
    required this.ceo,
    required this.iban,
    required this.bic,
  });
}

class Employee {
  final String name;
  final String email;
  final String position;
  final String department;
  final String bankAccount;
  final String panCard;
  final String location;
  final String cryptoAddress;
  final String cryptoCurrency;

  Employee({
    required this.name,
    required this.email,
    required this.position,
    required this.department,
    required this.bankAccount,
    required this.panCard,
    required this.location,
    required this.cryptoAddress,
    required this.cryptoCurrency,
  });
}

class Payslip {
  final Company company;
  final Employee employee;
  final DateTime paymentDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double basicSalary;
  final double hra;
  final double bonus;
  final double otherAllowances;
  final double taxWithholding;
  final double socialSecurity;
  final double healthInsurance;
  final double otherDeductions;
  final String payslipNumber;

  Payslip({
    required this.company,
    required this.employee,
    required this.paymentDate,
    required this.periodStart,
    required this.periodEnd,
    required this.basicSalary,
    required this.hra,
    required this.bonus,
    required this.otherAllowances,
    required this.taxWithholding,
    required this.socialSecurity,
    required this.healthInsurance,
    required this.otherDeductions,
    required this.payslipNumber,
  });

  double get totalEarnings => basicSalary + hra + bonus + otherAllowances;
  double get totalDeductions => taxWithholding + socialSecurity + healthInsurance + otherDeductions;
  double get netPay => totalEarnings - totalDeductions;

  static Company heyFlutterCompany() {
    return Company(
      name: 'HeyFlutter UG (haftungsbeschränkt)',
      address: 'Kassel, Germany',
      website: 'www.heyflutter.com',
      ceo: 'Johannes Milke',
      iban: 'DE58 1001 0123 3355 6907 35',
      bic: 'QNTODEB2XXX',
    );
  }

  static Employee kamleshPanwar() {
    return Employee(
      name: 'Kamlesh Panwar',
      email: 'kkamlesh286@gmail.com',
      position: 'Flutter Developer',
      department: 'Product Engineering',
      bankAccount: '70010392360',
      panCard: 'GXTPK7054L',
      location: 'Kassel, Germany',
      cryptoAddress: '0x61717eee1c05918c8a7c9c5a5606907141711ca5',
      cryptoCurrency: 'USDT',
    );
  }
}
