const Order = require('../models/Order');

// Create a new order
exports.createOrder = async (req, res) => {
    try {
        const { products, totalAmount, customer, paymentType } = req.body;
        // req.user is populated by the auth middleware
        const buyerId = req.user.id;

        const newOrder = new Order({
            buyer: buyerId,
            products,
            totalAmount,
            customer,
            paymentType,
            status: 'Pending'
        });

        const savedOrder = await newOrder.save();
        res.status(201).json(savedOrder);
    } catch (error) {
        console.error('Error creating order:', error);
        res.status(500).json({ message: 'Server error creating order' });
    }
};

// Get orders for the logged-in user (Buyer)
exports.getMyOrders = async (req, res) => {
    try {
        const orders = await Order.find({ buyer: req.user.id }).sort({ createdAt: -1 });
        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: 'Server error fetching orders' });
    }
};

// Get available orders for Riders (Pending orders with no rider assigned)
exports.getAvailableOrders = async (req, res) => {
    try {
        // Basic logic: Find orders that are confirmed/pending and have no rider
        // You might want to filter by location later
        const orders = await Order.find({
            status: { $in: ['Pending', 'Confirmed'] },
            rider: null
        }).sort({ createdAt: -1 });

        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: 'Server error fetching available orders' });
    }
};

// Get single order by ID with full details
exports.getOrderById = async (req, res) => {
    try {
        const { orderId } = req.params;
        const order = await Order.findById(orderId)
            .populate('buyer', 'name email')
            .populate('rider', 'name phone')
            .populate('products.product', 'name price');

        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        res.json(order);
    } catch (error) {
        console.error('Error fetching order:', error);
        res.status(500).json({ message: 'Server error fetching order' });
    }
};

// Pick/Accept an order (Rider assigns themselves)
exports.pickOrder = async (req, res) => {
    try {
        const { orderId } = req.params;
        const order = await Order.findById(orderId);

        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        if (order.rider) {
            return res.status(400).json({ message: 'Order already assigned to a rider' });
        }

        order.rider = req.user.id;
        order.status = 'Picked';

        const updatedOrder = await order.save();
        res.json(updatedOrder);
    } catch (error) {
        console.error('Error picking order:', error);
        res.status(500).json({ message: 'Server error picking order' });
    }
};

// Update Order Status (For Riders: Picked, OnTheWay, Delivered)
exports.updateOrderStatus = async (req, res) => {
    try {
        const { orderId } = req.params;
        const { status } = req.body;

        // Validate status against allowed values
        const allowedStatuses = ['Picked', 'OnTheWay', 'Delivered', 'Cancelled'];
        if (!allowedStatuses.includes(status)) {
            return res.status(400).json({ message: 'Invalid status update' });
        }

        const order = await Order.findById(orderId);
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        // Assign rider if not already assigned (and status implies action)
        if (!order.rider && req.user.role === 'rider') {
            order.rider = req.user.id;
        }

        order.status = status;
        if (status === 'Delivered' && order.paymentType === 'Cash') {
            order.paymentStatus = 'Paid';
        }

        const updatedOrder = await order.save();
        res.json(updatedOrder);
    } catch (error) {
        console.error('Error updating status:', error);
        res.status(500).json({ message: 'Server error updating status' });
    }
};
