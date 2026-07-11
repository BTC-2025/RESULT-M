import express from 'express';
import { registerPre, verifySignupOtp, login, forgotPassword, resetPassword } from '../controllers/authController';

const router = express.Router();

router.post('/register', registerPre);
router.post('/register/verify', verifySignupOtp);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

export default router;
