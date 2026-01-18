const app = require('./app');
const { connectDB } = require('./config/db');
const { PORT } = require('./config/env');
const dashboardRoutes = require('./routes/dashboardRoutes');

// Connect to Database
connectDB();

app.use('/api/dashboard', dashboardRoutes);

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
