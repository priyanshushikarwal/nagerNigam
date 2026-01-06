# DISCOM Bill Manager - Quick Start Guide

## 🚀 Application is Running!

The DISCOM Bill Manager desktop application is now running on your Windows machine.

## 📋 Quick Navigation

### Login Page
- **Username**: `firma`, `firmb`, or `firmc`
- **Password**: `password1`, `password2`, or `password3` respectively

### After Login
1. Select your DISCOM (AVVNL, JVVNL, or JDVVNL)
2. You'll be taken to the Bill Reminder Dashboard

## 🎯 Main Features

### Dashboard
- View all bills categorized by status:
  - 📅 **Upcoming Bills** (due in future)
  - ⚠️ **Due Today** (due today)
  - 🔴 **Overdue Bills** (past due date)
- Auto-refreshes every 5 seconds
- Click any bill to view/edit details

### Adding a New Bill
1. Click on **Bills** section (or directly from dashboard)
2. Click **"New Bill"** button
3. Fill in the required fields:
   - **Tender Number (TN)**: Group identifier for related bills
   - **Bill Number**: Unique bill identifier
   - **Amount**: Bill amount in ₹
   - **Due Date**: Payment deadline
   - **Description**: Additional details
4. Click **Save**

### Recording a Payment
1. Open any unpaid bill
2. Check the **"Mark as Paid"** checkbox
3. The **Payment Date** field appears (auto-filled with today's date)
4. Add **Payment Remarks** if needed
5. Click **"Add Photos"** to attach:
   - Payment receipts
   - Bank screenshots
   - Challans
   - Any payment proof
6. Click **Save**
7. System automatically records the "Last Edited" timestamp

## 💡 Tips

- **Multiple Photos**: You can attach multiple photos per bill as payment proof
- **Edit Anytime**: Click on any bill card to edit details
- **Date Tracking**: The system tracks both creation date and last edit date
- **DISCOM Specific**: Each DISCOM has completely separate data
- **Logout**: Use the logout button in the dashboard to switch firms or DISCOMs

## 🏢 Firm Management

The application supports 3 firms:
- **Firm A**: For first company's billing
- **Firm B**: For second company's billing  
- **Firm C**: For third company's billing

Each firm can manage bills for all 3 DISCOMs independently.

## 📊 Dashboard Color Coding

- **Blue** = Upcoming bills (no immediate action needed)
- **Orange** = Due today (pay today to avoid delay)
- **Red** = Overdue (requires immediate attention)

## 🔄 Workflow Example

1. **Login** as `firma` with password `password1`
2. **Select** AVVNL as your DISCOM
3. **View Dashboard** - initially empty for new installations
4. **Add a Bill**:
   - TN: `TN-2024-001`
   - Bill Number: `BILL-001`
   - Amount: `50000`
   - Due Date: (select a date)
   - Description: `Monthly electricity charges`
5. **Bill appears on dashboard** in appropriate category
6. When payment is made:
   - Open the bill
   - Mark as paid
   - Add payment date
   - Upload payment receipt
   - Add remarks: "Paid via NEFT"
   - Save

## 🛠️ Troubleshooting

### Application won't start?
```powershell
flutter clean
flutter pub get
flutter run -d windows
```

### Database issues?
The database is stored in your Documents folder. Delete it to start fresh:
```
C:\Users\YourName\Documents\isar\
```

### Need to regenerate database schemas?
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📧 Support

For issues or questions, refer to the main README.md file.

## 🎉 You're All Set!

Start managing your DISCOM bills efficiently with automatic reminders and payment tracking!
