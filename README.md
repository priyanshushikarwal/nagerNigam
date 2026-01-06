# DISCOM Bill Manager

A comprehensive Flutter desktop application for managing DISCOM (Distribution Company) electricity bills with payment tracking, reminders, and multi-firm support.

## Features

### 1. **Login & Firm Selection**
- Support for 3 different firms (Firm A, B, C)
- After login, users select their DISCOM:
  - AVVNL (Ajmer Vidyut Vitran Nigam Limited)
  - JVVNL (Jaipur Vidyut Vitran Nigam Limited)
  - JDVVNL (Jodhpur Vidyut Vitran Nigam Limited)
- Each DISCOM has its own separate dashboard and data

**Default Login Credentials:**
- Firm A: `firma` / `password1`
- Firm B: `firmb` / `password2`
- Firm C: `firmc` / `password3`

### 2. **Bill Reminder Dashboard**
- **Upcoming Bills**: Shows bills with future due dates
- **Due Today**: Displays bills that are due on the current date
- **Overdue Bills**: Lists bills past their due date with days overdue count
- Auto-refresh functionality (refreshes every 5 seconds)
- Color-coded sections for easy identification

### 3. **TN (Tender Number) Selection & Bill Listing**
- Bills grouped by Tender Number
- Complete payment details for each bill including:
  - Bill number
  - Amount
  - Due date
  - Payment status
  - Payment date (if paid)
  - Remarks and notes

### 4. **Payment Details Entry & Edit**
- **Auto-date feature**: Current date automatically appears when adding payment
- **Last edited tracking**: Shows when a bill was last modified
- **Photo upload**: Attach payment proofs, screenshots, challans, etc.
- **Remarks field**: Add notes with each payment
- Complete bill information entry:
  - Tender Number (TN)
  - Bill Number
  - Amount
  - Due Date
  - Description
  - Payment status (paid/unpaid)

## Technology Stack

- **Framework**: Flutter 3.29.3
- **UI Library**: Fluent UI (Windows-style design)
- **State Management**: Riverpod
- **Database**: Isar (NoSQL local database)
- **Routing**: go_router
- **File Handling**: file_picker

## Getting Started

### Prerequisites

- Flutter SDK 3.29.3 or higher
- Windows OS (for desktop development)
- Git

### Installation

1. **Clone the repository**
```powershell
cd C:\Users\YourName\Desktop
git clone <repository-url>
cd discom_bill_manager
```

2. **Install dependencies**
```powershell
flutter pub get
```

3. **Generate Isar database schemas**
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the application**
```powershell
flutter run -d windows
```

## Project Structure

```
lib/
├── core/
│   ├── router.dart          # Navigation configuration
│   └── theme.dart           # App theming
├── data/
│   ├── database.dart        # Database initialization
│   └── models/
│       ├── bill.dart        # Bill data model
│       ├── customer.dart    # Customer data model
│       └── firm.dart        # Firm data model
├── features/
│   ├── auth/
│   │   ├── auth_provider.dart         # Authentication state
│   │   ├── login_screen.dart          # Login UI
│   │   └── discom_selection_screen.dart # DISCOM selection
│   ├── dashboard/
│   │   └── dashboard_screen.dart      # Main dashboard with reminders
│   ├── bills/
│   │   ├── bill_entry_screen.dart     # Add/Edit bills
│   │   └── bill_list_screen.dart      # List all bills
│   └── customers/
│       └── customer_list_screen.dart  # Customer management
└── main.dart                          # App entry point
```

## Usage Guide

### First Launch

1. The app will create a local database in your documents folder
2. Three default firms are pre-configured
3. Log in using any of the default credentials

### Adding a Bill

1. Navigate to Bills section
2. Click "New Bill"
3. Fill in:
   - Tender Number
   - Bill Number
   - Amount
   - Due Date
   - Description
4. Optionally mark as paid and add:
   - Payment date
   - Payment remarks
   - Upload payment proof photos
5. Click Save

### Managing Payments

1. View bills on the dashboard
2. Click on any bill to edit
3. Mark as paid when payment is made
4. Add payment date (auto-fills with current date)
5. Upload payment receipt/proof
6. Add any relevant remarks
7. System tracks last edited date automatically

### Dashboard Overview

- **Blue cards**: Upcoming bills
- **Orange cards**: Bills due today
- **Red cards**: Overdue bills
- Click any bill card to view/edit details

## Database Schema

### Firm Model
- ID, Name, Address, Contact info
- Username, Password (hashed)
- Selected DISCOM
- Last login date

### Bill Model
- Amount, Due Date, Payment Date
- Tender Number, Bill Number
- Description, Payment Remarks
- Payment photos (file paths)
- Created date, Last edited date
- Payment status flags

### Customer Model
- Name, Address, Consumer ID
- DISCOM assignment
- Contact information

## Development

### Running in Debug Mode
```powershell
flutter run -d windows
```

### Building Release Version
```powershell
flutter build windows --release
```

### Generating New Models
After adding/modifying Isar models:
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

## Future Enhancements

- Export bills to PDF/Excel
- Advanced filtering and search
- Payment analytics and reports
- Email/SMS reminders
- Multi-user roles and permissions
- Cloud sync capability
- Mobile app version

## Support

For issues or questions, please open an issue in the GitHub repository.

## License

[Add your license here]

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
