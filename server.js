const express = require('express');
const mongoose = require('mongoose');
const productRoutes = require('./routes/productRoutes');

const app = express();
app.use(express.json());

mongoose.connect('mongodb://localhost:27017/pos_app', {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

app.use('/api/products', productRoutes);

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});
