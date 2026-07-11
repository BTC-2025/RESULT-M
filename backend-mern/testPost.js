const http = require('http');
const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');

// Generate Token manually
const generateToken = (userId, role) => {
  return jwt.sign({ id: userId, role }, 'super_secret_jwt_key_123', {
    expiresIn: '7d',
  });
};

async function testPostCreation() {
  await mongoose.connect('mongodb://root:password@localhost:27017/resulthub?authSource=admin');
  const User = mongoose.model('User', new mongoose.Schema({ email: String, role: String }, { strict: false }));
  const user = await User.findOne();
  
  if (!user) {
    console.log("No user found!");
    process.exit(1);
  }

  const token = generateToken(user._id.toString(), user.role || 'USER');
  console.log("Using Token:", token);

  const requestData = {
    postType: "UPDATE",
    text: "This is an automated test post via script",
    category: null,
    locationName: null
  };

  const boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
  
  // Construct multipart body
  let body = '';
  
  // Append data field (stringified JSON)
  body += `--${boundary}\r\n`;
  body += `Content-Disposition: form-data; name="data"\r\n\r\n`;
  body += `${JSON.stringify(requestData)}\r\n`;
  body += `--${boundary}--\r\n`;

  const req = http.request('http://localhost:8080/api/v1/posts', {
    method: 'POST',
    headers: {
      'Content-Type': `multipart/form-data; boundary=${boundary}`,
      'Authorization': `Bearer ${token}`,
      'Content-Length': Buffer.byteLength(body)
    }
  }, (res) => {
    let data = '';
    res.on('data', c => data += c);
    res.on('end', () => {
      console.log("Response Status:", res.statusCode);
      console.log("Response Body:", data);
      process.exit(0);
    });
  });

  req.on('error', (e) => {
    console.error("Error:", e);
    process.exit(1);
  });

  req.write(body);
  req.end();
}

testPostCreation();
