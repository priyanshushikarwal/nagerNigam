# DISCOM Bill Manager - Production-Ready Windows Desktop App

## 🏗️ Architecture Overview

This is an enterprise-grade, **100% offline** Windows desktop application built with Flutter 3.x for managing electricity bill reminders, payments, and document storage across multiple DISCOMs (Distribution Companies).

### Key Features
- ✅ **Fully Offline** - No internet required, all data stored locally
- ✅ **SQLite Database** - Robust, ACID-compliant data persistence
- ✅ **Bcrypt Security** - Industry-standard password hashing
- ✅ **Multi-DISCOM Support** - AVVNL, JVVNL, JDVVNL
- ✅ **Backup & Restore** - ZIP-based full data backups
- ✅ **File Management** - Local proof document storage
- ✅ **Auto-Backup** - Scheduled automatic backups every 7 days
- ✅ **Export Capabilities** - CSV and PDF export
- ✅ **Enterprise UI** - Professional Fluent Design

## 📁 Data Storage Locations

All data is stored in:
```
C:\Users\<Username>\AppData\Roaming\DISCOMBillManager\
├── data\
│   └── discom_data.db          # SQLite database
├── files\
│   ├── AVVNL\                  # Payment proofs for AVVNL
│   ├── JVVNL\                  # Payment proofs for JVVNL
│   └── JDVVNL\                 # Payment proofs for JDVVNL
└── backups\                    # Auto-generated backups
    └── backup_AVVNL_2025-11-08_14-30.zip
```

## 🗄️ Database Schema

### Tables

#### **users**
- `id` - Primary key
- `username` - Unique username
- `password_hash` - Bcrypt hashed password
- `is_admin` - Admin flag
- `created_at`, `updated_at` - Timestamps

#### **firms** (DISCOMs)
- `id` - Primary key  
- `name` - DISCOM name (AVVNL, JVVNL, JDVVNL)
- `code` - Unique code
- `description` - Full name
- `created_at` - Timestamp

#### **bills**
- `id` - Primary key
- `firm_id` - Foreign key to firms
- `tn_number` - Tender Number
- `bill_date` - Bill issued date
- `due_date` - Payment due date
- `amount` - Bill amount
- `status` - Pending / Paid / Overdue
- `remarks` - Notes
- `created_at`, `updated_at` - Timestamps

#### **payments**
- `id` - Primary key
- `bill_id` - Foreign key to bills
- `payment_date` - Date of payment
- `amount_paid` - Amount paid
- `proof_path` - Local file path to proof
- `remarks` - Payment notes
- `last_edited` - Last modification time
- `created_at` - Created timestamp

#### **settings**
- `key` - Setting key (primary)
- `value` - Setting value
- `updated_at` - Timestamp

#### **backups**
- `id` - Primary key
- `backup_path` - Path to backup file
- `backup_date` - Backup timestamp
- `file_size` - Backup size in bytes
- `firm_id` - Optional firm association
- `is_auto` - Auto-backup flag

## 🔐 Security

### Password Hashing
- **Algorithm**: Bcrypt with salt rounds = 10
- **Default Admin**: username `admin`, password `admin123`
- All passwords stored as hashed strings, never plain text

### Data Protection
- Local-only storage
- No cloud transmission
- File-based proof storage
- Encrypted backup support (optional)

## 🎯 Core Services

### 1. DatabaseService
- SQLite initialization
- Schema creation and migrations
- Directory management
- CRUD operations

### 2. AuthService
- Login/logout
- Password change
- Admin password reset
- User management

### 3. BillService
- Bill CRUD operations
- Status tracking (Pending/Paid/Overdue)
- Search and filtering
- Dashboard statistics

### 4. PaymentService
- Payment entry and editing
- File upload handling
- Proof document management
- Payment history

### 5. BackupService
- Full database + files backup to ZIP
- Restore from backup
- Auto-backup scheduling
- Backup history tracking

### 6. ExportService
- CSV export for bills and payments
- PDF report generation
- Customizable date ranges

## 🖥️ UI Structure

### Navigation
- **Side Navigation Bar**
  - Dashboard
  - Bills
  - Payments
  - Backup & Restore
  - Settings
  - Logout

### Screens

#### 1. Login Screen
- Username and password fields
- Remember me option
- Change password link
- Admin reset option

#### 2. DISCOM Selection
- Dropdown with 3 DISCOMs
- Description for each
- Persistent selection

#### 3. Dashboard
- Statistics cards:
  - Total bills
  - Due soon (within 7 days)
  - Overdue bills
  - Recently paid
- Search bar
- Quick action buttons
- Bill status overview

#### 4. Bills Screen
- Sortable DataTable
- Add/Edit/Delete bills
- Filter by status, date, TN number
- Export to CSV/PDF

#### 5. Payments Screen
- Payment entry form
- File upload for proofs
- Preview uploaded documents
- Payment history

#### 6. Backup Screen
- Backup now button
- Restore from backup
- Backup history
- Auto-backup settings

#### 7. Settings
- Theme toggle (Light/Dark)
- Auto-backup configuration
- Password change
- User management (admin only)

## 🔧 Technical Stack

### Core
- **Flutter**: 3.29.3
- **Dart**: 3.7.2
- **Platform**: Windows Desktop

### Packages
```yaml
# Database
sqflite: ^2.4.1
sqflite_common_ffi: ^2.3.4  # Windows FFI support

# Security
crypto: ^3.0.6
bcrypt: ^1.1.3

# File System
path_provider: ^2.1.5
path: ^1.9.0
file_picker: ^8.3.7

# Backup
archive: ^3.6.1

# Export
csv: ^6.0.0
pdf: ^3.11.1
printing: ^5.13.4

# State Management
flutter_riverpod: ^2.6.1

# Navigation
go_router: ^17.0.0

# UI
fluent_ui: ^4.11.5

# Utilities
intl: ^0.19.0
```

## 🚀 Installation & Setup

### Prerequisites
- Windows 10/11
- Flutter SDK 3.29.3+
- Visual Studio 2022 with C++ tools

### Installation Steps

1. **Clone Repository**
```powershell
git clone <repository-url>
cd discom_bill_manager
```

2. **Install Dependencies**
```powershell
flutter pub get
```

3. **Run Application**
```powershell
flutter run -d windows
```

4. **Build Release**
```powershell
flutter build windows --release
```

The `.exe` will be in:
```
build\windows\x64\runner\Release\discom_bill_manager.exe
```

## 📖 Usage Guide

### First Launch
1. App creates database and directories automatically
2. Default admin account: `admin` / `admin123`
3. Login and select a DISCOM
4. Dashboard shows empty state initially

### Adding a Bill
1. Navigate to Bills
2. Click "Add Bill"
3. Fill in:
   - TN Number (Tender Number)
   - Bill Date
   - Due Date
   - Amount
   - Remarks (optional)
4. Status auto-set to "Pending"
5. Save

### Recording a Payment
1. Navigate to Payments
2. Click "Add Payment"
3. Select bill from dropdown
4. Enter:
   - Payment Date (defaults to today)
   - Amount Paid
   - Remarks
5. Upload proof (PDF, image, etc.)
6. Save
7. Bill status auto-updates to "Paid"

### Creating Backups
1. Navigate to Backup
2. Click "Backup Now"
3. Choose destination folder
4. ZIP file created with:
   - Database snapshot
   - All proof files
5. Backup entry logged in database

### Restoring Backup
1. Navigate to Backup
2. Click "Restore Backup"
3. Select `.zip` backup file
4. Confirm restoration
5. App restores all data and files
6. Restart application

### Auto-Backup
- Enabled by default
- Runs every 7 days
- Saves to `backups/` folder
- Configure in Settings

## 🔍 Advanced Features

### Search & Filter
- Search by TN number
- Filter by status (Pending/Paid/Overdue)
- Date range filtering
- Full-text search in remarks

### Export Options
- **CSV Export**: All bills with payments
- **PDF Reports**: Formatted bill statements
- **Date Range**: Export specific periods
- **DISCOM Specific**: Export per DISCOM

### Theme Support
- Light Mode (default)
- Dark Mode
- Persisted in settings
- System theme sync (optional)

### Admin Features
- User management
- Password resets
- System-wide settings
- Backup management

## 🛠️ Development

### Project Structure
```
lib/
├── main.dart                  # Entry point
├── models/
│   ├── bill.dart             # Bill & Payment models
│   └── firm.dart             # DISCOM models
├── services/
│   ├── database_service.dart # SQLite management
│   ├── auth_service.dart     # Authentication
│   ├── bill_service.dart     # Bill operations
│   ├── payment_service.dart  # Payment operations
│   ├── backup_service.dart   # Backup/restore
│   └── export_service.dart   # CSV/PDF export
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── change_password_screen.dart
│   ├── discom_selection_screen.dart
│   ├── dashboard_screen.dart
│   ├── bills/
│   │   ├── bills_screen.dart
│   │   └── bill_form_screen.dart
│   ├── payments/
│   │   ├── payments_screen.dart
│   │   └── payment_form_screen.dart
│   ├── backup_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── stat_card.dart
    ├── bill_data_table.dart
    ├── payment_list.dart
    └── file_preview.dart
```

### Code Style
- Follow official Dart style guide
- Use Riverpod for state management
- Implement error handling everywhere
- Add comments for complex logic
- Write unit tests for services

### Testing
```powershell
# Run all tests
flutter test

# Run specific test
flutter test test/services/database_service_test.dart

# Generate coverage
flutter test --coverage
```

## 📊 Performance

- **Startup Time**: < 2 seconds
- **Database Queries**: Indexed for fast lookups
- **File Operations**: Async to prevent UI blocking
- **Memory Usage**: < 150 MB typical
- **Storage**: ~10 MB base + data/files

## 🐛 Troubleshooting

### Database Issues
```powershell
# Delete database to start fresh
Remove-Item "$env:APPDATA\DISCOMBillManager\data\*.db"
```

### Build Errors
```powershell
flutter clean
flutter pub get
flutter build windows
```

### Missing DLLs
Ensure Visual Studio C++ redistributables are installed.

## 📝 Changelog

### Version 1.0.0
- Initial release
- Full offline functionality
- All 3 DISCOMs supported
- Backup & restore system
- CSV/PDF export

## 📄 License

[Add your license here]

## 👥 Contributors

[Add contributors]

## 📧 Support

For issues or questions:
- Open an issue on GitHub
- Email: support@example.com
- Documentation: [Wiki link]

---

**Built with ❤️ using Flutter for Windows Desktop**
