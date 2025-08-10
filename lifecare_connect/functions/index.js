const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(functions.config().sendgrid.key);

exports.sendAdminApprovalEmail = functions.https.onRequest(async (req, res) => {
  const { email, name } = req.body;
  const msg = {
    to: email,
    from: 'admin@lifecare.rhemn.org.ng', // Use your verified sender
    subject: 'Admin Approval Required',
    text: `Hello ${name}, your account requires admin approval.`,
  };
  try {
    await sgMail.send(msg);
    res.status(200).send('Email sent');
  } catch (err) {
    res.status(500).send('Failed to send email');
  }
});
