# 🚀 Build & Run Guide - RHDTE Directory

## Quick Start

### 1. Open in Xcode
```bash
cd /Users/fadil369/brainsait-map/rhdte-directory-ios-new
open RHDTEDirectory.xcodeproj
```

### 2. Verify GeoJSON is in the bundle (already wired)
- Location: `Resources/saudi_providers_unified.geojson` (2.1 MB)
- Xcode: Target → Build Phases → Copy Bundle Resources should list the file
- No manual add is needed; this repo already wires the GeoJSON into the bundle

### 3. Build Settings
- **Deployment Target**: iOS 16.0+
- **Swift Version**: Swift 5.9+
- **Devices**: iPhone, iPad

### 4. Build & Run
```
⌘ + R (or click Run button)
```

Choose: iPhone 15 Pro Simulator (or any iOS 16+ device)

---

## Expected Behavior

### On Launch
1. App loads instantly
2. FacilityDataManager parses 2,951 facilities
3. Console prints: `✅ Loaded 2951 facilities`
   - If you see a warning about a lower count, re-check Copy Bundle Resources
4. Tab bar shows 5 tabs

### Tab 1: Map
- Should display Riyadh-centered map
- 2,951 colored markers appear
- Search bar and filter chips work
- Tap markers for facility info

### Tab 2: Directory  
- Lists all 2,951 facilities
- Stats cards at top show:
  - Total: 2,951
  - Avg Rating: 3.9
  - With Contact: 460
  - Source breakdown
- Search is instant
- Filters work

### Tab 3: Saved
- Empty state initially
- Save facilities from Map/Directory
- Persists across app launches

### Tab 4: Dashboard
- Shows analytics (if DashboardView implemented)

### Tab 5: Profile
- Shows personal stats
- Data source breakdown
- About info

---

## Troubleshooting

### Problem: "GeoJSON file not found in bundle"
**Solution**: 
1. Check Build Phases → Copy Bundle Resources
2. Ensure `saudi_providers_unified.geojson` is listed
3. Clean build folder (⌘ + Shift + K) and rebuild

### Problem: "No facilities loading"
**Solution**:
1. Check Console for error messages
2. Verify file is in bundle and not duplicated outside `Resources/`
3. Check file size (should be ~2.1 MB) and count (~2,951 features)

### Problem: Map shows no markers
**Solution**:
1. Verify `facilityDataManager.facilities.count > 0`
2. Check region coordinates (Riyadh: 24.7136, 46.6753)
3. Ensure MapView is using `EnhancedMapView`

### Problem: Build errors
**Solution**:
1. Update to latest Xcode (15.0+)
2. Clean build folder
3. Delete Derived Data
4. Rebuild project

---

## File Checklist

Before building, verify these files exist:

**Models:**
- [x] Models/HealthFacility.swift
- [x] Models/Facility.swift

**Services:**
- [x] Services/FacilityDataManager.swift
- [x] Services/APIService.swift

**Views:**
- [x] Views/Map/EnhancedMapView.swift
- [x] Views/Directory/EnhancedDirectoryView.swift
- [x] Views/Saved/SavedFacilitiesView.swift
- [x] Views/Profile/ProfileView.swift
- [x] Views/Dashboard/DashboardView.swift

**Resources:**
- [x] Resources/saudi_providers_unified.geojson (2.1 MB)
- [x] Resources/Assets.xcassets

**App:**
- [x] App/RHDTEDirectoryApp.swift

---

## Performance Expectations

| Metric | Expected Value |
|--------|----------------|
| Initial Load | < 1 second |
| Facility Count | 2,951 |
| Memory Usage | ~10-15 MB |
| Search Speed | Instant |
| Filter Speed | Instant |
| App Size | ~3-4 MB |

---

## Testing Checklist

### Functional Testing
- [ ] App launches successfully
- [ ] 2,951 facilities load
- [ ] Map shows all markers
- [ ] Search works in Directory
- [ ] Filters apply correctly
- [ ] Sorting options work
- [ ] Save/unsave facilities
- [ ] Saved persists after restart
- [ ] Profile shows correct stats

### UI Testing
- [ ] All tabs accessible
- [ ] Navigation works smoothly
- [ ] Search bar responsive
- [ ] Filter chips toggle
- [ ] Facility cards display properly
- [ ] Icons show correctly
- [ ] Colors match design (Blue/Green/Orange)

### Data Testing
- [ ] Google Places data (502 facilities)
- [ ] HDX data (2,154 facilities)
- [ ] OSM data (295 facilities)
- [ ] Ratings display correctly
- [ ] Contact info shows when available
- [ ] Addresses format properly

---

## Console Output

Expected console messages on launch:

```
✅ Loaded 2951 facilities
```

On filter/search:
```
Filtering 2951 facilities...
Found 150 results
```

On save:
```
Saved facility: <facility-id>
```

---

## Deployment

### TestFlight
1. Archive app (Product → Archive)
2. Validate archive
3. Upload to App Store Connect
4. Add to TestFlight
5. Invite testers

### App Store
1. Prepare screenshots
2. Write description
3. Set pricing
4. Submit for review

---

## Next Steps After Launch

1. **Monitor Analytics**
   - Track most viewed facilities
   - Monitor search queries
   - Analyze filter usage

2. **Gather Feedback**
   - TestFlight beta feedback
   - User reviews
   - Feature requests

3. **Plan Updates**
   - Add facility detail sheets
   - Implement directions
   - Enable direct calling
   - Add sharing features

---

## Support

**Issues?** Check:
1. INTEGRATION_SUMMARY.md
2. Console output
3. Xcode build logs

**Questions?**
- Email: support@brainsait.com
- GitHub: https://github.com/Fadil369/rhdte-directory-ios

---

**Version**: 1.0.0  
**Last Updated**: November 27, 2025  
**Status**: ✅ Ready to Build

**Happy Building! 🚀**
