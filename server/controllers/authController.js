const User = require('../models/User');
// In a real app, use bcrypt and jwt. For skeleton, we'll keep it simple or implement mockup.
// I will implement basic JWT/Bcrypt placeholders.

const register = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        let user = await User.findOne({ email });
        if (user) return res.status(400).json({ msg: 'User already exists' });

        user = new User({ name, email, password, role: role || 'user' });
        // TODO: Hash password here
        await user.save();

        res.status(201).json({ msg: 'User registered successfully', user });
    } catch (err) {
        res.status(500).json({ msg: 'Server error' });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        console.log('Login attempt:', email, password); // DEBUG
        const user = await User.findOne({ email });

        if (!user) {
            console.log('User not found in DB'); // DEBUG
            return res.status(400).json({ msg: 'Invalid credentials (User not found)' });
        }

        console.log('User found:', user.email, 'Role:', user.role); // DEBUG
        console.log('Stored pass:', user.password, 'Input pass:', password); // DEBUG

        if (user.password !== password) {
            console.log('Password mismatch'); // DEBUG
            return res.status(400).json({ msg: 'Invalid credentials (Password mismatch)' });
        }

        // TODO: Sign JWT
        const token = "mock_token_123456";

        res.json({ token, user });
    } catch (err) {
        res.status(500).json({ msg: 'Server error' });
    }
};

const forgotPassword = async (req, res) => {
    const { email } = req.body;
    console.log(`Password reset requested for: ${email}`);
    // Simulate delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    res.status(200).json({ msg: 'Password reset link sent to your email' });
};

module.exports = { register, login, forgotPassword };
