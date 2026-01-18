const mongoose = require('mongoose');
const User = require('../models/User');
const { connectDB } = require('../config/db');
require('dotenv').config({ path: '../.env' });

const debugUsers = async () => {
    try {
        await connectDB();
        const users = await User.find({}, 'name email role');
        console.log('--- USER DATABASE DUMP ---');
        users.forEach(u => {
            console.log(`Email: ${u.email} | Role: ${u.role} | Name: ${u.name}`);
        });
        console.log('--------------------------');
        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

debugUsers();
