const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const authMiddleware = require('../middleware/authMiddleware');

// Protected Route (Requires Login)
// router.get('/stats', authMiddleware, dashboardController.getDashboardStats);

// For testing ease right now, allowing public access or you can add middleware back
router.get('/stats', dashboardController.getDashboardStats);

module.exports = router;
