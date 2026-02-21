# Google Apps Script — Lead Capture Setup

This connects the [CodeLedger landing page](https://codeledger.dev) email form to a Google Sheet so you can collect leads for follow-up marketing.

## Steps

### 1. Create a Google Sheet

Go to [sheets.google.com](https://sheets.google.com) and create a new spreadsheet.
Name it something like **"CodeLedger Leads"**.

### 2. Open the Apps Script editor

In the spreadsheet menu bar: **Extensions > Apps Script**

This opens the script editor in a new tab.

### 3. Paste the script

Delete any default code in the editor and paste the full contents of `Code.gs` (from this directory).

Save the project (Ctrl+S). Name it **"CodeLedger Lead Capture"** or similar.

### 4. Initialize the sheet headers

In the Apps Script editor:
1. Select `initSheet` from the function dropdown (next to the Run button)
2. Click **Run**
3. Authorize when prompted (Google will ask you to grant spreadsheet access)

Go back to your spreadsheet — you should see headers in row 1:
`Timestamp | Email | Company | Role | Source | Received At`

### 5. Deploy as a Web App

1. Click **Deploy > New deployment**
2. Click the gear icon and select **Web app**
3. Set:
   - **Description**: `Lead capture v1`
   - **Execute as**: `Me`
   - **Who has access**: `Anyone`
4. Click **Deploy**
5. Authorize again if prompted
6. **Copy the Web App URL** — it looks like:
   ```
   https://script.google.com/macros/s/AKfycbx.../exec
   ```

### 6. Paste the URL into the [landing page](https://codeledger.dev)

Open `docs/index.html` and find the configuration section near the top of the `<script>` block:

```javascript
// Paste your Google Apps Script web app URL here (see google-apps-script/SETUP.md)
const FORM_ENDPOINT = '';
```

Paste your URL between the quotes:

```javascript
const FORM_ENDPOINT = 'https://script.google.com/macros/s/AKfycbx.../exec';
```

Save the file and deploy.

### 7. Test it

1. Open the [landing page](https://codeledger.dev) in a browser
2. Fill in the email form and submit
3. Check your Google Sheet — a new row should appear within a few seconds

## Updating the script

If you change `Code.gs`, paste the updated code into the Apps Script editor and create a **new deployment version**:

1. **Deploy > Manage deployments**
2. Click the pencil (edit) icon on your active deployment
3. Under **Version**, select **New version**
4. Click **Deploy**

The URL stays the same — no changes needed in `index.html`.

## Columns captured

| Column | Source | Description |
|--------|--------|-------------|
| Timestamp | Client | ISO timestamp from the user's browser |
| Email | Form | Work email (required field) |
| Company | Form | Company name (optional) |
| Role | Form | Role dropdown value (optional) |
| Source | Client | Always `landing-page` |
| Received At | Server | ISO timestamp from Google's server |
