import nodemailer from 'nodemailer';

export const sendOtpEmail = async (to: string, otp: string, name: string) => {
  // Move transporter inside function so process.env is fully loaded
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '465'),
    secure: true,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  const mailOptions = {
    from: process.env.SMTP_FROM_EMAIL || '"ResultHub" <noreply@resulthub.com>',
    to,
    subject: 'Your ResultHub Verification Code',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
        <h2 style="color: #333;">Welcome to ResultHub, ${name}!</h2>
        <p style="color: #555; font-size: 16px;">Please use the following verification code to complete your registration:</p>
        <div style="background-color: #f4f4f4; padding: 15px; border-radius: 5px; text-align: center; margin: 20px 0;">
          <h1 style="color: #007bff; margin: 0; letter-spacing: 5px;">${otp}</h1>
        </div>
        <p style="color: #777; font-size: 14px;">This code will expire in 15 minutes.</p>
        <p style="color: #777; font-size: 14px;">If you did not request this, please ignore this email.</p>
      </div>
    `,
  };

  try {
    // Check if credentials exist, otherwise just log to console for dev mode
    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
      console.log('----------------------------------------------------');
      console.log('DEV MODE: SMTP Credentials not set in .env');
      console.log(`Mocking Email to: ${to}`);
      console.log(`Subject: ${mailOptions.subject}`);
      console.log(`OTP Code: ${otp}`);
      console.log('----------------------------------------------------');
      return true;
    }
    
    await transporter.sendMail(mailOptions);
    return true;
  } catch (error) {
    console.error('Error sending email:', error);
    return false;
  }
};
