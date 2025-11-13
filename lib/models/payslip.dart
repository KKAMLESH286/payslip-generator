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
  final String cryptoAddress;
  final String cryptoCurrency;

  Employee({
    required this.name,
    required this.email,
    required this.position,
    required this.cryptoAddress,
    required this.cryptoCurrency,
  });
}

class Payslip {
  final Company company;
  final Employee employee;
  final DateTime paymentDate;
  final String paymentPeriod;
  final double grossSalary;
  final double netSalary;
  final Map<String, double> deductions;
  final Map<String, double> additions;
  final String payslipNumber;

  Payslip({
    required this.company,
    required this.employee,
    required this.paymentDate,
    required this.paymentPeriod,
    required this.grossSalary,
    required this.netSalary,
    required this.deductions,
    required this.additions,
    required this.payslipNumber,
  });

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
      cryptoAddress: '0x61717eee1c05918c8a7c9c5a5606907141711ca5',
      cryptoCurrency: 'USDT',
    );
  }
}
