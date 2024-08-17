String generateEmailBody(String userName, String startDate, String endDate) {
  return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      margin: 0;
      padding: 0;
      color: #333;
    }
    .container {
      width: 80%;
      margin: auto;
      padding: 20px;
    }
    .header {
      background-color: #f4f4f4;
      padding: 10px;
      text-align: center;
      border-bottom: 2px solid #e0e0e0;
    }
    .content {
      margin: 20px 0;
    }
    .footer {
      font-size: 0.8em;
      color: #888;
      text-align: center;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Greetings!</h1>
    </div>
    <div class="content">
      <p>Dear $userName,</p>
      <p>We are pleased to send you the attached report for the period of $startDate to $endDate. Please review the document at your convenience.</p>
      <p>If you have any questions or need further assistance, feel free to reach out to us through the appropriate channels.</p>
    </div>
    <div class="footer">
      <p>Please do not reply to this email address. For any inquiries or support, please contact our support team directly.</p>
    </div>
  </div>
</body>
</html>
''';
}
