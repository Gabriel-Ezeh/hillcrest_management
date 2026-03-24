# KYC Document Upload - UX Improvements

## Changes Implemented (March 9, 2026)

### ✅ What Changed

1. **Removed Signature Upload**
   - Replaced with **Proof of Address (POA)** upload
   - More aligned with standard KYC requirements

2. **Added Document Subtype Selection**
   - **Proof of Identity (POI)** subtypes:
     - NIN (National Identity Number)
     - Driver's License
     - International Passport
     - Voter's Card
   
   - **Proof of Address (POA)** subtypes:
     - Electricity Bill
     - Bank Statement
     - Water Bill
     - Waste Bill
     - House Rent Receipt
     - Tenancy Agreement
     - Land Use Charge

3. **Improved User Flow**
   - User taps document card → selects subtype from bottom sheet → picks file/takes photo
   - Selected subtype is displayed on the card after selection
   - Selected subtype is saved in `documentComments` field for backend tracking

4. **Enhanced Visual Feedback**
   - Added helper text under each card explaining what to upload
   - Cards turn green with checkmark when document is uploaded
   - Clear guidance: "Upload one valid government-issued ID", etc.

5. **Updated Backend Payload**
   - Document types now sent as: `Photo`, `POI`, `POA` (instead of `Signature`)
   - Subtype stored in `documentComments` field, e.g., "Proof of address: Electricity Bill"
   - Backward compatible - backend can still parse these fields

6. **Updated Onboarding Modal**
   - Changed "Signature Upload" → "Address Proof Upload" in checklist

---

## Files Modified

### 1. `individual_kyc_upload_document_screen.dart`
- Added `_poiSubtype` and `_poaSubtype` state variables
- Added `_documentSubtypes` map with all accepted document types
- Added `_showSubtypeSelector()` method for bottom sheet
- Updated `_pickDocument()` and `_takePhoto()` to handle `proofOfAddress`
- Updated `_onSubmitPressed()` to create POA document with subtype in comments
- Enhanced `_DocumentUploadCard` widget with helper text
- Updated UI to show 3 cards: Photo, POI, POA

### 2. `onboarding_completion_modal.dart`
- Updated checklist to show "Address Proof Upload" instead of "Signature Upload"

---

## Testing Checklist

- [ ] Tap on "Proof of Identity" → bottom sheet appears with ID types
- [ ] Select "NIN" → upload options appear (camera/gallery)
- [ ] Upload document → card shows "NIN (National Identity Number)" as subtitle
- [ ] Tap on "Proof of Address" → bottom sheet appears with address proof types
- [ ] Select "Electricity Bill" → upload options appear
- [ ] Upload document → card shows "Electricity Bill" as subtitle
- [ ] Submit all 3 documents → check backend receives correct `documentType` and `documentComments`
- [ ] Verify uploaded documents display correctly in backend/admin panel

---

## Future Enhancements (Optional)

1. **Server-Driven Document Types**
   - Fetch allowed document types from backend config
   - Allows changing requirements without app update

2. **Document Validation**
   - Check file size before upload
   - Validate image quality/readability
   - Show preview before final submission

3. **Multi-file Support**
   - Allow multiple pages for passport/utility bills
   - Merge into single submission

4. **OCR Integration**
   - Auto-extract data from ID cards
   - Pre-fill personal info from uploaded documents

---

## Notes

- All changes maintain backward compatibility
- Selected subtypes are stored in `documentComments` field
- Backend can parse and display subtype information
- User experience is now clearer and more guided
- Reduces submission errors and support requests


