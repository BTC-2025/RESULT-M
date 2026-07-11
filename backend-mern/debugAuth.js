const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');

async function debugAuth() {
  await mongoose.connect('mongodb://root:password@localhost:27017/resulthub?authSource=admin');
  const User = mongoose.model('User', new mongoose.Schema({ email: String, role: String }, { strict: false }));
  const user = await User.findOne();
  
  if (!user) {
    console.log("No user found!");
    process.exit(1);
  }

  const token = jwt.sign({ id: user._id.toString(), role: user.role }, 'super_secret_jwt_key_123', {
    expiresIn: '7d',
  });
  console.log("Token:", token);

  try {
    const decoded = jwt.verify(token, 'super_secret_jwt_key_123');
    console.log("Decoded ID:", decoded.id);
    console.log("Type of Decoded ID:", typeof decoded.id);
    
    // Simulate what requireAuth does
    const currentUser = await User.findById(decoded.id);
    console.log("CurrentUser found by findById:", currentUser ? "YES" : "NO");
    if (currentUser) {
      console.log("CurrentUser email:", currentUser.email);
    }
  } catch (err) {
    console.error("JWT Error:", err);
  }
  process.exit(0);
}

debugAuth();
