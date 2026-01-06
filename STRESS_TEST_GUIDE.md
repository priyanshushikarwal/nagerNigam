# Stress Test Generator - User Guide

## Overview

The Stress Test Generator is a developer tool that creates large amounts of realistic test data to validate the app's performance with hundreds of TNs, bills, and payments.

## Accessing the Tool

1. Open the app and log in
2. Navigate to **Settings** screen (from sidebar)
3. Scroll to **Developer Tools** section
4. Click **🧪 Stress Test Generator** button

## Features

### Data Generation Configuration

- **Number of TNs**: Configure how many Tender Numbers to generate (1-10,000)
  - Default: 500 TNs
- **Bills per TN Range**: Set minimum and maximum bills per tender
  - Default: 3-7 bills per TN
- **Payments per Bill Range**: Set minimum and maximum payments per bill
  - Default: 0-3 payments per bill

### Realistic Data Generation

The generator creates realistic test data with:

- **TN Details**:
  - Format: `TN-{DISCOM}-{INDEX}/{YEAR}` (e.g., `TN-JDVVNL-001/2025`)
  - Random DISCOM codes: JDVVNL, JVVNL, AVVNL
  - Realistic PO numbers and work descriptions
  - Historical creation dates (within last year)

- **Bill Information**:
  - Invoice amounts: ₹50,000 to ₹5,00,000
  - Manual deductions:
    - TDS Amount: 1.5% to 3% of invoice
    - GST TDS Amount: 1.5% to 3%
    - TCS Amount: 0.8% to 2%
    - CSD Amount: 0% or 2.5% (random)
  - Scrap amounts, MD/LD penalties
  - Work order numbers and consignment names
  - Invoice dates, bill dates, due dates

- **Payment Records**:
  - Transaction numbers (UTR, CHQ, NEFT, RTGS, IMPS)
  - Payment amounts: 30-70% of bill amount per payment
  - Payment dates within 15-105 days of bill date
  - Linked to work orders and consignments

### Progress Tracking

- Real-time progress bar showing completion percentage
- Status messages:
  - "Initializing..."
  - "Generating TN 1/500..."
  - "Calculating payment totals..."
  - "Complete!"
- Estimated time: 2-5 minutes for 500 TNs

### Results Summary

After generation, the tool displays:
- ✅ Total TNs generated
- ✅ Total bills created
- ✅ Total payments added
- ⏱️ Duration in seconds
- 📊 Average bills per TN and payments per bill

Example result:
```
Stress Test SUCCESS!
✅ Generated 500 TNs
✅ Generated 2,453 bills
✅ Generated 3,679 payments
⏱️ Duration: 142s
📊 Average: 4.9 bills/TN, 1.5 payments/bill
```

## Usage Instructions

### Generating Test Data

1. **Configure Parameters**:
   - Adjust TN count (e.g., 500 for full test)
   - Set bills per TN range (e.g., 3-7)
   - Set payments per bill range (e.g., 0-3)

2. **Review Estimates**:
   - Check estimated totals displayed below configuration
   - Example: `Estimated data: ~2,500 bills, ~3,750 payments`

3. **Click "🚀 Generate Stress Test Data"**:
   - Progress bar will show real-time status
   - Wait for completion (do not close app)
   - Success dialog will appear when done

4. **Verify Data**:
   - Navigate to Dashboard to see new data
   - Check TN Dashboard for generated tenders
   - Open bills to verify realistic values

### Clearing Test Data

⚠️ **WARNING: This action is permanent and cannot be undone!**

1. Click **"🗑️ Clear ALL Data (Danger!)"** button
2. Confirm deletion in dialog
3. All tenders, bills, and payments will be removed
4. Database will be empty (except firm configurations)

## Performance Testing

### Recommended Test Scenarios

1. **Small Dataset** (Development):
   - 50 TNs, 3-5 bills/TN, 1-2 payments/bill
   - ~200 bills, ~300 payments
   - Fast generation (~15 seconds)

2. **Medium Dataset** (Testing):
   - 200 TNs, 3-7 bills/TN, 0-3 payments/bill
   - ~1,000 bills, ~1,500 payments
   - Generation time: ~1 minute

3. **Large Dataset** (Stress Test):
   - 500 TNs, 3-7 bills/TN, 0-3 payments/bill
   - ~2,500 bills, ~3,750 payments
   - Generation time: ~2-5 minutes

### What to Test

After generating data, validate:

- **Dashboard Performance**:
  - Load time with thousands of bills
  - Scrolling smoothness
  - Status chip rendering

- **TN Dashboard**:
  - Load time for 500+ tenders
  - Search functionality with large dataset
  - Status calculations accuracy

- **Bill List Screen**:
  - Pagination performance
  - Filtering and sorting speed
  - Partially paid status display

- **Payment Entry**:
  - Invoice dropdown with thousands of bills
  - Payment summary calculations
  - Validation with partial payments

- **PDF Generation**:
  - Export speed with many bills
  - File size management
  - PDF rendering quality

- **Search & Filter**:
  - Search response time
  - Filter combinations
  - Result accuracy

## Technical Details

### Data Structure

Generated in batches to prevent UI freezing:
- Processes 50 TNs at a time
- Updates progress every batch
- Automatic payment total recalculation

### Database Operations

- Uses Drift ORM for efficient inserts
- Batch inserts for performance
- Automatic foreign key linking
- CASCADE DELETE for cleanup

### Memory Management

- Clears temporary data after each batch
- Progress callbacks prevent blocking
- Async operations for responsiveness

## Troubleshooting

### "No firms available" Error

**Problem**: Generator cannot find any firms in database.

**Solution**:
- Navigate to DISCOM Selection screen
- Verify at least one firm exists (JDVVNL, JVVNL, or AVVNL)
- If no firms, app may need database reset

### Generation Takes Too Long

**Problem**: Progress seems stuck or very slow.

**Solution**:
- Reduce TN count (try 100 instead of 500)
- Reduce bills per TN range (try 2-4)
- Close other apps to free memory
- Wait patiently - large datasets take time

### App Becomes Unresponsive

**Problem**: UI freezes during generation.

**Solution**:
- Wait - batch processing may be completing
- If frozen >5 minutes, force close and restart
- Reduce dataset size for next attempt

### Wrong Data Appears in Dashboard

**Problem**: Generated data doesn't show expected values.

**Solution**:
- Refresh dashboard (pull to refresh or re-navigate)
- Check provider cache invalidation
- Restart app to reload all data

## Safety Notes

1. **Backup First**: Always backup your database before using stress test generator
2. **Development Only**: Only use in development/testing environments
3. **Clear After Testing**: Remove test data before production use
4. **Monitor Resources**: Watch memory and storage usage with large datasets
5. **No Undo**: Clearing data is permanent - there is no recovery option

## Best Practices

1. Start with small datasets (50 TNs) to verify functionality
2. Gradually increase size to test performance limits
3. Clear test data between different test scenarios
4. Document performance metrics for comparison
5. Test on target hardware (similar to user devices)
6. Verify data integrity after generation
7. Check payment calculations are correct
8. Validate status updates work properly

## Support

If you encounter issues:
1. Check error messages in result dialog
2. Review console logs (if running in debug mode)
3. Try smaller dataset sizes
4. Clear all data and regenerate
5. Restart application
6. Report persistent issues with:
   - Configuration used (TN count, ranges)
   - Error message details
   - System specifications

---

**Version**: 1.0  
**Last Updated**: January 2025  
**Compatibility**: DISCOM Bill Manager v9.0+
