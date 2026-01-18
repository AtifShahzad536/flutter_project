const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    buyer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    products: [
        {
            product: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Product',
                required: true
            },
            quantity: {
                type: Number,
                required: true,
                min: 1
            },
            price: {
                type: Number,
                required: true
            }
        }
    ],
    totalAmount: {
        type: Number,
        required: true
    },
    // Specific Customer Details for Rider
    customer: {
        name: { type: String, required: true },
        phone: { type: String, required: true },
        address: { type: String, required: true },
        mapLink: { type: String } // Optional: Google Maps link
    },
    // Pickup Location (Store/Warehouse)
    pickupLocation: {
        address: { type: String, required: true },
        lat: { type: Number, required: true },
        lng: { type: Number, required: true }
    },
    // Delivery Location (Customer Address)
    deliveryLocation: {
        address: { type: String, required: true },
        lat: { type: Number, required: true },
        lng: { type: Number, required: true }
    },
    // Payment Information
    paymentType: {
        type: String,
        enum: ['Cash', 'Online'],
        default: 'Cash',
        required: true
    },
    paymentStatus: {
        type: String,
        enum: ['Pending', 'Paid'],
        default: 'Pending'
    },
    // Order Status Lifecycle
    status: {
        type: String,
        enum: ['Pending', 'Confirmed', 'Picked', 'OnTheWay', 'Delivered', 'Cancelled'],
        default: 'Pending'
    },
    // Rider Assignment
    rider: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Order', orderSchema);
