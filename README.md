# HeyFlutter Payslip Generator

A Flutter application for generating professional payslips for HeyFlutter UG (haftungsbeschränkt), Kassel, Germany.

## Features

- **Professional Payslip Generation**: Create detailed payslips with company and employee information
- **PDF Export**: Generate payslips as PDF documents that can be printed or saved
- **Customizable Salary Components**: Add custom deductions and additions to the base salary
- **Pre-configured Company Details**: Includes HeyFlutter company information and bank details
- **Crypto Payment Support**: Displays cryptocurrency payment details (USDT wallet address)
- **User-Friendly Interface**: Clean and intuitive Material Design UI

## Company Information

- **Name**: HeyFlutter UG (haftungsbeschränkt)
- **Location**: Kassel, Germany
- **Website**: www.heyflutter.com
- **CEO**: Johannes Milke

### Bank Details
- **IBAN**: DE58 1001 0123 3355 6907 35
- **BIC**: QNTODEB2XXX

## Employee Details (Default)

- **Name**: Kamlesh Panwar
- **Email**: kkamlesh286@gmail.com
- **Position**: Flutter Developer
- **Salary**: €600
- **Payment Method**: Cryptocurrency (USDT)
- **Wallet Address**: 0x61717eee1c05918c8a7c9c5a5606907141711ca5

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd payslip-generator
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Usage

1. **Launch the Application**: Open the app on your device or emulator
2. **Review Details**: The company and employee information is pre-filled
3. **Set Payslip Details**:
   - Payslip Number (auto-generated but can be modified)
   - Payment Period (e.g., "November 2025")
   - Payment Date (use the date picker)
   - Gross Salary (default: €600)
4. **Add Additions** (optional): Click the "+" button to add bonuses or other additions
5. **Add Deductions** (optional): Click the "+" button to add taxes or other deductions
6. **Review Net Salary**: The net salary is calculated automatically
7. **Generate PDF**: Click "Generate Payslip PDF" to create and preview the payslip

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── models/
│   └── payslip.dart                   # Data models for Company, Employee, and Payslip
├── screens/
│   └── payslip_generator_screen.dart  # Main UI screen
└── services/
    └── pdf_generator.dart             # PDF generation service
```

## Dependencies

- **flutter**: SDK
- **pdf**: ^3.10.7 - PDF document creation
- **printing**: ^5.11.1 - PDF preview and printing
- **intl**: ^0.18.1 - Internationalization and date formatting
- **path_provider**: ^2.1.1 - File system access

## Features Breakdown

### Payslip Components

- Company header with branding
- Payslip identification (number, period, date)
- Employee information
- Salary breakdown with gross/net amounts
- Customizable additions and deductions
- Payment details (cryptocurrency)
- Company bank details
- Professional footer

### PDF Layout

The generated PDF includes:
- A4 page format
- Professional styling with headers and borders
- Clear sections for all information
- Currency formatting (EUR)
- Date formatting (DD.MM.YYYY)

## Development

### Adding New Features

To extend the application:

1. **Modify Company Details**: Edit the `heyFlutterCompany()` method in `lib/models/payslip.dart`
2. **Add New Employee**: Create a new static method in the `Payslip` class
3. **Customize PDF Layout**: Modify `lib/services/pdf_generator.dart`
4. **Update UI**: Edit `lib/screens/payslip_generator_screen.dart`

### Customization

You can customize:
- Company logo (requires adding assets)
- Color scheme in `main.dart`
- PDF styling in `pdf_generator.dart`
- Default values in the UI

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## License

This project is private and proprietary to HeyFlutter UG (haftungsbeschränkt).

## Contact

For questions or support, contact:
- **Email**: kkamlesh286@gmail.com
- **Company**: www.heyflutter.com

---

**Created for HeyFlutter UG (haftungsbeschränkt)**
