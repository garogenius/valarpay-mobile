# Target Savings UI - API Integration Update

**Date**: 2026-02-09  
**Objective**: Ensure Target Savings feature accurately reflects API data rather than mock data

## Summary of Changes

This update refines the Target Savings module to use real API data throughout the application, replacing hardcoded mock values with dynamic data fetched from the backend.

---

## 1. **Data Models Enhanced**

### SavingsPlan Model (`savings_models.dart`)
**Added Fields:**
- `durationMonths` (int) - Duration of the savings plan in months
- `endDate` (DateTime?) - Calculated or API-provided end date for the plan

**Purpose**: Support accurate display of plan duration and end dates in the UI.

### EasyLifePlan Model (`easylife_models.dart`)
**Added Fields:**
- `contributionFrequency` (String) - Frequency of contributions (DAILY, WEEKLY, MONTHLY)
- `autoDebitEnabled` (bool) - Whether auto-debit is enabled for the plan

**Purpose**: Display complete plan configuration in the details screen.

---

## 2. **Product Data Integration**

### CreateSavingsPlanScreen
**Changes:**
- Fetches `SavingsProduct` data on initialization
- Filters products by type (VALAR_AUTO_SAVE for FIXED, FLEX_SAVE for TARGET)
- Uses real interest rates from product data instead of hardcoded 17%
- Duration picker now displays actual interest rates dynamically
- Success modal shows real interest rate and calculated total payable
- Removed non-API fields from TARGET UI (Frequency, Preferred Time)
- Simplified TARGET creation to match API requirements
- Accurate duration calculation: parses selected duration for FIXED, calculates from dates for TARGET

### CreateEasyLifePlanScreen
**Changes:**
- Fetches `EasyLifeProduct` data on initialization
- Uses real contribution frequencies from product data
- Dynamic frequency picker based on API-supported frequencies
- Default frequency set from product configuration

### FinanceMainScreen
**Changes:**
- Fetches both savings and EasyLife products on initialization
- Displays real interest rates for all product cards:
  - Fixed Savings: Uses VALAR_AUTO_SAVE product rate
  - Target Savings: Uses FLEX_SAVE product rate
  - EasyLife Savings: Uses EasyLife product rate
- Fallback to 17% if product data not available

---

## 3. **Details Screens Updated**

### SavingsDetailsScreen
**Changes:**
- Uses real `interestRate` from plan data
- Calculates interest earned based on actual rate
- Uses `endDate` from API if available, otherwise calculates from `durationMonths`
- Displays accurate days left until plan maturity
- All mock dates and durations replaced with calculated values

### EasyLifeDetailsScreen
**Changes:**
- Displays real `contributionFrequency` from plan data
- Shows actual `autoDebitEnabled` status
- Uses `durationDays` from API for days left calculation

---

## 4. **API Data Flow**

### Data Fetching Strategy:
1. **Products**: Fetched once on screen initialization
2. **Plans**: Fetched on Finance Hub load and refreshed after mutations
3. **Plan Details**: Fetched when viewing individual plan details

### Key Repositories:
- `SavingsRepository`: Handles savings products and plans
- `EasyLifeRepository`: Handles EasyLife products and plans

### State Management:
- Uses Riverpod `StateNotifier` pattern
- `DataState` wrapper for loading/error/data states
- Automatic UI updates on state changes

---

## 5. **Removed Mock Data**

### Before:
- Hardcoded interest rates (10%, 17%, 20%)
- Fixed durations ("3 Months", "6 Months", etc.)
- Mock dates ("10 September, 2025")
- Placeholder days left ("200 Days")
- Static contribution frequencies

### After:
- Dynamic interest rates from API
- Calculated durations based on plan data
- Real dates from `createdAt` and `endDate` fields
- Accurate days left calculations
- API-driven contribution frequencies

---

## 6. **UI Refinements**

### Target Savings Creation:
- Removed "Frequency" selector (not in API)
- Removed "Preferred Time" selector (not in API)
- Renamed "Desired saving Amount Per Day" to "Est. Daily Saving (Informational)"
- Simplified to match API contract: name, amount, start/end dates

### Success Modals:
- Display real interest rates
- Calculate total payable based on actual rates
- Show accurate duration from user selection

### Product Cards:
- All interest rates now dynamic
- Fallback values ensure UI never breaks

---

## 7. **Data Mapping**

### API Field Aliases Supported:
- `name` / `title` → `name`
- `goalAmount` / `targetAmount` → `goalAmount`
- `totalSaved` → `totalSaved`
- `currentAmount` → `currentAmount`

### Default Values:
- `durationMonths`: 3 (if not provided)
- `contributionFrequency`: 'DAILY' (if not provided)
- `autoDebitEnabled`: false (if not provided)
- `interestRate`: 0.17 (17% fallback)

---

## 8. **Calculation Logic**

### Interest Earned (Approximate):
```dart
plan.currentAmount * plan.interestRate / 12
```

### Total Payable:
```dart
depositAmount * (1 + interestRate)
```

### Days Left:
```dart
(endDate ?? createdAt.add(Duration(days: durationMonths * 30)))
  .difference(DateTime.now())
  .inDays
```

### Duration Months (TARGET):
```dart
(endDate.difference(startDate).inDays / 30).ceil().clamp(1, 120)
```

---

## Testing Recommendations

1. **Create Plans**: Test both FIXED and TARGET plan creation
2. **View Details**: Verify all fields show real data
3. **Product Loading**: Ensure interest rates load correctly
4. **Edge Cases**: Test with missing optional fields
5. **Date Calculations**: Verify days left and end dates are accurate
6. **Funding/Withdrawal**: Test plan mutations and data refresh

---

## API Endpoints Used

- `GET /api/v1/savings/products` - Fetch savings products
- `GET /api/v1/savings/plans` - Fetch user savings plans
- `POST /api/v1/savings/plans` - Create savings plan
- `GET /api/v1/easylife-savings/product` - Fetch EasyLife product
- `GET /api/v1/easylife-savings/plans` - Fetch user EasyLife plans
- `POST /api/v1/easylife-savings/plans` - Create EasyLife plan

---

## Files Modified

1. `lib/features/models/savings_models.dart`
2. `lib/features/models/easylife_models.dart`
3. `lib/features/dashboard/view/finance/savings/create_savings_plan_screen.dart`
4. `lib/features/dashboard/view/finance/easylife/create_easylife_plan_screen.dart`
5. `lib/features/dashboard/view/finance/finance_main_screen.dart`
6. `lib/features/dashboard/view/finance/savings/savings_details_screen.dart`

---

## Next Steps

- **Backend Verification**: Ensure API returns all expected fields
- **Error Handling**: Add user-friendly error messages for API failures
- **Loading States**: Consider skeleton screens during data fetching
- **Offline Support**: Cache product data for offline viewing
- **Analytics**: Track plan creation success rates
