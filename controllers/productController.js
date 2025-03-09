const Product = require('../models/product');

const saveProductList = async (productList) => {
    try {
        await Product.insertMany(productList);
        console.log('Product list saved successfully');
    } catch (error) {
        console.error('Error saving product list:', error);
    }
};

module.exports = {
    saveProductList,
    // ...existing code...
};
