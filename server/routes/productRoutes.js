const express = require('express');
const router = express.Router();
const { getProducts, getProductById, createProduct, getProductsBySeller } = require('../controllers/productController');

router.get('/', getProducts);
router.get('/:id', getProductById);
router.post('/', createProduct);

router.get('/seller/:sellerId', getProductsBySeller);

module.exports = router;
