# Setting Up Your Update Repository

## The Issue
The error "Could not fetch update information" means the app cannot access your version.json file at:
```
https://raw.githubusercontent.com/priyanshushikarwal/discom_bill_manager_updates/v1.0.0/version.json
```

This happens because either:
1. ❌ The repository doesn't exist yet
2. ❌ The branch `v1.0.0` doesn't exist
3. ❌ The `version.json` file isn't in the repository

## 🔧 Solution: Create Your Update Repository

### Step 1: Create the GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `discom_bill_manager_updates`
3. Set as **Public** (required for raw.githubusercontent.com access)
4. Click "Create repository"

### Step 2: Create version.json File

Create a file named `version.json` with this content:

```json
{
  "version": "1.0.1",
  "url": "https://github.com/priyanshushikarwal/discom_bill_manager_updates/releases/download/v1.0.1/discom_bill_manager.exe",
  "notes": "Initial release with auto-update support.\n\n• PDF generation improvements\n• Bug fixes\n• Performance enhancements",
  "mandatory": false
}
```

### Step 3: Upload version.json to Repository

**Option A: Via GitHub Web Interface**
1. Click "Add file" → "Create new file"
2. Name: `version.json`
3. Paste the content above
4. Click "Commit changes"

**Option B: Via Git Command Line**
```bash
cd /path/to/local/folder
echo '{"version":"1.0.1","url":"https://github.com/priyanshushikarwal/discom_bill_manager_updates/releases/download/v1.0.1/discom_bill_manager.exe","notes":"Initial release","mandatory":false}' > version.json
git init
git add version.json
git commit -m "Initial version.json"
git remote add origin https://github.com/priyanshushikarwal/discom_bill_manager_updates.git
git push -u origin main
```

### Step 4: Create v1.0.0 Branch (Current Setup)

Your app is currently configured to use the `v1.0.0` branch. Create it:

```bash
git checkout -b v1.0.0
git push origin v1.0.0
```

**OR** update your settings_screen.dart to use `main` branch instead:

Change from:
```dart
final updateService = UpdateService(
  versionJsonUrl: "https://raw.githubusercontent.com/priyanshushikarwal/discom_bill_manager_updates/v1.0.0/version.json",
);
```

To:
```dart
final updateService = UpdateService(
  versionJsonUrl: "https://raw.githubusercontent.com/priyanshushikarwal/discom_bill_manager_updates/main/version.json",
);
```

### Step 5: Test the URL

Open this URL in your browser to verify it works:
```
https://raw.githubusercontent.com/priyanshushikarwal/discom_bill_manager_updates/main/version.json
```

You should see the JSON content. If you get a 404, the file isn't accessible yet.

---

## 🚀 For Testing Without GitHub (Temporary)

If you want to test locally before setting up GitHub:

### Option 1: Use a Local Test Server

1. Create a folder: `C:\temp\update_test`
2. Create `version.json` in that folder:
```json
{
  "version": "1.0.1",
  "url": "http://localhost:8000/discom_bill_manager.exe",
  "notes": "Test update",
  "mandatory": false
}
```
3. Start a simple HTTP server:
```powershell
cd C:\temp\update_test
python -m http.server 8000
```
4. Update your settings_screen.dart:
```dart
final updateService = UpdateService(
  versionJsonUrl: "http://localhost:8000/version.json",
);
```

### Option 2: Use GitHub Gist

1. Go to https://gist.github.com/
2. Create a new gist with filename `version.json`
3. Paste your version JSON
4. Click "Create public gist"
5. Click "Raw" button
6. Copy the URL (will look like: `https://gist.githubusercontent.com/...`)
7. Use this URL in your app

---

## 📦 When You're Ready to Deploy Real Updates

### Step 1: Build Your Release

```bash
flutter build windows --release
```

The EXE will be at:
```
build\windows\x64\runner\Release\discom_bill_manager.exe
```

### Step 2: Create a GitHub Release

1. Go to your repository: `https://github.com/priyanshushikarwal/discom_bill_manager_updates`
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.1`
4. Title: `Version 1.0.1`
5. Description: Your release notes
6. Upload your EXE file
7. Click "Publish release"

### Step 3: Get the Download URL

After publishing, your EXE URL will be:
```
https://github.com/priyanshushikarwal/discom_bill_manager_updates/releases/download/v1.0.1/discom_bill_manager.exe
```

### Step 4: Update version.json

Update the `url` field in your version.json to point to the release:

```json
{
  "version": "1.0.1",
  "url": "https://github.com/priyanshushikarwal/discom_bill_manager_updates/releases/download/v1.0.1/discom_bill_manager.exe",
  "notes": "What's new in this version...",
  "mandatory": false
}
```

Commit and push this change.

---

## 🔍 Troubleshooting

### Error: "Could not fetch update information"

**Check:**
- ✅ Repository is **public** (not private)
- ✅ File is named exactly `version.json` (case-sensitive)
- ✅ File is in the repository root
- ✅ Branch name matches (v1.0.0 or main)
- ✅ URL is correct in settings_screen.dart
- ✅ Internet connection is working

**Test URL manually:**
Open in browser: `https://raw.githubusercontent.com/priyanshushikarwal/discom_bill_manager_updates/main/version.json`

If 404 → File doesn't exist or repo is private
If JSON appears → Working correctly!

### Error: "Download failed"

- ✅ EXE file exists in GitHub release
- ✅ Release is published (not draft)
- ✅ URL in version.json is correct
- ✅ File size isn't too large

---

## 📝 Quick Setup Checklist

- [ ] Create GitHub repository: `discom_bill_manager_updates`
- [ ] Make repository **Public**
- [ ] Create `version.json` file in repository root
- [ ] Commit to main branch (or create v1.0.0 branch)
- [ ] Verify URL works in browser
- [ ] Test "Check for Updates" in app
- [ ] Create first release with EXE
- [ ] Update version.json with release URL
- [ ] Test full update flow

---

## 🎯 Recommended Setup

**For simplicity, I recommend:**

1. Use the `main` branch instead of `v1.0.0`
2. Keep `version.json` always on main branch
3. Use tags for releases: v1.0.1, v1.0.2, etc.

**Update your settings_screen.dart:**
```dart
final updateService = UpdateService(
  versionJsonUrl: "https://raw.githubusercontent.com/priyanshushikarwal/discom_bill_manager_updates/main/version.json",
);
```

This way you only need to update the JSON file content, not manage branches.

---

## Need Help?

If you continue to get errors:
1. Check the Flutter debug console for detailed error messages
2. Verify the URL in a browser
3. Check GitHub repository settings (must be public)
4. Try the Gist method for quick testing

Good luck! 🚀
