const express = require('express');
const router = express.Router();
const { createOrder, getMyOrders, getAvailableOrders, updateOrderStatus, getOrderById, pickOrder } = require('../controllers/orderController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all routes
router.use(authMiddleware);

// Buyer Routes
router.post('/', createOrder);
router.get('/my-orders', getMyOrders);

// Rider Routes (Should theoretically have role checks, keeping simple for now)
router.get('/available', getAvailableOrders);
router.get('/:orderId', getOrderById);
router.post('/:orderId/pick', pickOrder);
router.put('/:orderId/status', updateOrderStatus);

module.exports = router;
