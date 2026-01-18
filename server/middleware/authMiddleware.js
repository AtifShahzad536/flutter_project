const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authMiddleware = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');

        if (!token) {
            return res.status(401).json({ message: 'No authentication token, authorization denied' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret_key');
        req.user = await User.findById(decoded.id).select('-password');

        if (!req.user) {
            return res.status(401).json({ message: 'Token is valid but user not found' });
        }

        next();
    } catch (err) {
        res.status(401).json({ message: 'Token is not valid' });
    }
};

module.exports = authMiddleware;
