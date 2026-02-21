/**
 * CodeLedger — Landing Page Lead Capture
 *
 * Google Apps Script that receives POST submissions from the landing page
 * email capture form and appends them to the active Google Sheet.
 *
 * Deploy as: Web App  (Execute as: Me, Access: Anyone)
 * See SETUP.md for full instructions.
 */

// ── Sheet setup ────────────────────────────────────────────────────

/**
 * Run this once to create column headers in the active sheet.
 */
function initSheet() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  sheet.getRange(1, 1, 1, 6).setValues([[
    'Timestamp', 'Email', 'Company', 'Role', 'Source', 'Received At'
  ]]);
  sheet.setFrozenRows(1);
  sheet.getRange(1, 1, 1, 6).setFontWeight('bold');
}

// ── POST handler ───────────────────────────────────────────────────

/**
 * Receives JSON POST from the landing page form.
 * Expected body: { email, company, role, timestamp, source }
 */
function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);

    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    sheet.appendRow([
      data.timestamp || '',
      data.email || '',
      data.company || '',
      data.role || '',
      data.source || '',
      new Date().toISOString()   // server-side receive time
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({ status: 'ok' }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (err) {
    return ContentService
      .createTextOutput(JSON.stringify({ status: 'error', message: err.message }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// ── CORS preflight (browsers may send OPTIONS before POST) ─────────

function doGet(e) {
  return ContentService
    .createTextOutput(JSON.stringify({ status: 'ok', message: 'Lead capture endpoint is live.' }))
    .setMimeType(ContentService.MimeType.JSON);
}
