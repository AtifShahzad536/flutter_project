const Order = require('../models/Order');

exports.getDashboardStats = async (req, res) => {
    try {
        // In a real app, you would filter by req.user.id (Rider ID)
        // const riderId = req.user.id; 

        // 1. Fetch Summary Stats (Mocking mostly as we don't have full DB population script yet)

        // Total Earnings (Mock or Aggregate)
        const totalEarnings = 1250.50;

        // Completed Trips
        const completedTrips = await Order.countDocuments({ status: 'Delivered' });

        // Active Orders
        const activeOrder = await Order.findOne({ status: { $in: ['Pending', 'Picked'] } }).sort({ createdAt: -1 });

        // 2. Graph Data (Last 7 Days Earnings - Mocked for smooth UI)
        const earningsGraph = [
            { day: 'Mon', amount: 45 },
            { day: 'Tue', amount: 80 },
            { day: 'Wed', amount: 60 },
            { day: 'Thu', amount: 120 },
            { day: 'Fri', amount: 90 },
            { day: 'Sat', amount: 150 },
            { day: 'Sun', amount: 130 },
        ];

        // 3. Recent Orders
        const recentOrders = await Order.find()
            .sort({ createdAt: -1 })
            .limit(5)
            .select('orderId status amount address createdAt');

        res.json({
            success: true,
            data: {
                totalEarnings,
                completedTrips,
                hoursOnline: "6h 20m", // Mock
                rating: 4.9, // Mock
                earningsGraph,
                activeOrder,
                recentOrders
            }
        });

    } catch (error) {
        console.error('Dashboard Stats Error:', error);
        res.status(500).json({ success: false, message: 'Server Error' });
    }
};
