const Product = require('../models/Product');

// Get all products
const getProducts = async (req, res) => {
    try {
        const products = await Product.find().populate('sellerId', 'name email');
        res.json(products);
    } catch (err) {
        res.status(500).json({ msg: 'Server error' });
    }
};

// Get single product
const getProductById = async (req, res) => {
    try {
        const product = await Product.findById(req.params.id).populate('sellerId', 'name email');
        if (!product) return res.status(404).json({ msg: 'Product not found' });
        res.json(product);
    } catch (err) {
        res.status(500).json({ msg: 'Server error' });
    }
};

// Create product (Seller only - simplified auth for now)
const createProduct = async (req, res) => {
    try {
        const { name, description, price, imageUrl, category, sellerId } = req.body;

        const newProduct = new Product({
            name,
            description,
            price,
            imageUrl,
            category,
            sellerId // In real app, get from req.user
        });

        const product = await newProduct.save();
        res.json(product);
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server error' });
    }
};

// Get products by seller
const getProductsBySeller = async (req, res) => {
    try {
        const products = await Product.find({ sellerId: req.params.sellerId });
        res.json(products);
    } catch (err) {
        res.status(500).json({ msg: 'Server error' });
    }
};

module.exports = { getProducts, getProductById, createProduct, getProductsBySeller };
