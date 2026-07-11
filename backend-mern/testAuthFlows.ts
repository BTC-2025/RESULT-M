import mongoose from 'mongoose';
import dotenv from 'dotenv';
import bcrypt from 'bcryptjs';

dotenv.config();

const BASE_URL = 'http://localhost:3001/api/v1/auth';
const TEST_EMAIL = `test_${Date.now()}@example.com`;
const TEST_PASSWORD = 'TestPassword123!';
const TEST_NAME = 'Automated Tester';

async function fetchJson(endpoint: string, body: any) {
  const res = await fetch(`${BASE_URL}${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const data = await res.json();
  return { status: res.status, data };
}

async function runTests() {
  console.log(`\n🚀 STARTING COMPLETE AUTH FLOW TEST`);
  console.log(`Connecting to MongoDB...`);
  
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://root:password@localhost:27017/resulthub?authSource=admin');
  console.log(`✅ MongoDB Connected.\n`);

  try {
    // ----------------------------------------------------
    // 1. SIGN UP (PRE)
    // ----------------------------------------------------
    console.log(`[1/5] Testing Sign Up (Generate OTP)...`);
    const regRes = await fetchJson('/register', { email: TEST_EMAIL, password: TEST_PASSWORD, name: TEST_NAME });
    
    if (regRes.status !== 200) throw new Error(`Registration failed: ${JSON.stringify(regRes.data)}`);
    console.log(`✅ Sign Up Pre-registration successful. Email sent.`);

    // ----------------------------------------------------
    // 2. RETRIEVE OTP FROM DB (Simulate reading email)
    // ----------------------------------------------------
    const SignupOtp = mongoose.model('SignupOtp', new mongoose.Schema({ email: String, otp: String }, { strict: false }));
    const otpDoc = await SignupOtp.findOne({ email: TEST_EMAIL }).sort({ createdAt: -1 });
    
    if (!otpDoc) throw new Error('OTP not found in database!');
    console.log(`   (Intercepted OTP from DB: ${otpDoc.otp})`);

    // ----------------------------------------------------
    // 3. VERIFY OTP & CREATE ACCOUNT
    // ----------------------------------------------------
    console.log(`\n[2/5] Testing Verify OTP & Create Account...`);
    const verifyRes = await fetchJson('/register/verify', { email: TEST_EMAIL, otp: otpDoc.otp });
    
    if (verifyRes.status !== 200) throw new Error(`OTP Verification failed: ${JSON.stringify(verifyRes.data)}`);
    console.log(`✅ Account successfully created! JWT Token received.`);

    // ----------------------------------------------------
    // 4. LOGIN
    // ----------------------------------------------------
    console.log(`\n[3/5] Testing Login...`);
    const loginRes = await fetchJson('/login', { email: TEST_EMAIL, password: TEST_PASSWORD });
    
    if (loginRes.status !== 200) throw new Error(`Login failed: ${JSON.stringify(loginRes.data)}`);
    console.log(`✅ Login successful! User object returned.`);

    // ----------------------------------------------------
    // 5. FORGOT PASSWORD
    // ----------------------------------------------------
    console.log(`\n[4/5] Testing Forgot Password (Generate Reset OTP)...`);
    const forgotRes = await fetchJson('/forgot-password', { email: TEST_EMAIL });
    
    if (forgotRes.status !== 200) throw new Error(`Forgot Password failed: ${JSON.stringify(forgotRes.data)}`);
    console.log(`✅ Forgot Password successful. Reset OTP email sent.`);

    // ----------------------------------------------------
    // 6. RETRIEVE RESET OTP FROM DB (Simulate reading email)
    // ----------------------------------------------------
    const User = mongoose.model('User', new mongoose.Schema({ email: String }, { strict: false }));
    const userDoc = await User.findOne({ email: TEST_EMAIL });
    
    const PasswordResetToken = mongoose.model('PasswordResetToken', new mongoose.Schema({ user: mongoose.Schema.Types.ObjectId, token: String }, { strict: false }));
    const resetOtpDoc = await PasswordResetToken.findOne({ user: userDoc._id }).sort({ createdAt: -1 });
    
    if (!resetOtpDoc) throw new Error('Reset OTP not found in database!');
    console.log(`   (Intercepted Reset OTP from DB: ${resetOtpDoc.token})`);

    // ----------------------------------------------------
    // 7. RESET PASSWORD
    // ----------------------------------------------------
    console.log(`\n[5/5] Testing Reset Password...`);
    const NEW_PASSWORD = 'NewSecurePassword456!';
    const resetRes = await fetchJson('/reset-password', { email: TEST_EMAIL, otp: resetOtpDoc.token, newPassword: NEW_PASSWORD });
    
    if (resetRes.status !== 200) throw new Error(`Reset Password failed: ${JSON.stringify(resetRes.data)}`);
    console.log(`✅ Password successfully reset!`);

    // ----------------------------------------------------
    // 8. VERIFY NEW PASSWORD WITH LOGIN
    // ----------------------------------------------------
    console.log(`\n[Bonus] Testing Login with New Password...`);
    const loginNewRes = await fetchJson('/login', { email: TEST_EMAIL, password: NEW_PASSWORD });
    
    if (loginNewRes.status !== 200) throw new Error(`Login with new password failed: ${JSON.stringify(loginNewRes.data)}`);
    console.log(`✅ Login with new password successful!`);

    console.log(`\n🎉 ALL AUTH FLOWS TESTED SUCCESSFULLY WITH ZERO CRASHES! 🎉`);

  } catch (error: any) {
    console.error(`\n❌ TEST FAILED: ${error.message}`);
  } finally {
    await mongoose.connection.close();
  }
}

runTests();
