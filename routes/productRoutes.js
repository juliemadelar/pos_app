const express = require('express');
const router = express.Router();
const { saveProductList } = require('../controllers/productController');

router.post('/save-products', async (req, res) => {
    const productList = req.body;
    try {
        await saveProductList(productList);
        res.status(200).send('Product list saved successfully');
    } catch (error) {
        res.status(500).send('Error saving product list');
    }
});

module.exports = router;
