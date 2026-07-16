const express = require('express');
const productRouter = express.Router(); // 1. KHAI BÁO BIẾN NÀY ĐẦU TIÊN
const Product = require('../models/product'); // 2. Import model (chỉ cần 1 lần)
const {auth, vendorAuth} = require('../middleware/auth');

productRouter.post('/api/add-product', auth, vendorAuth, async (req, res) => {
    try {
        const { productName, productPrice, quantity, description, category, vendorId, fullName, subCategory, images } = req.body;
        
        // 3. Đổi tên biến mới thành 'newProduct' để tránh trùng với tên import 'Product'
        const newProduct = new Product({
            productName, 
            productPrice, 
            quantity, 
            description, 
            category, 
            vendorId,
            fullName,
            subCategory, 
            images
        });
        
        await newProduct.save();
        return res.status(201).json(newProduct);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

productRouter.get('/api/popular-products', async(req,res) => {
    try {
        const product = await Product.find({popular:true});
        if(!product || product.length == 0) {
            return res.status(404).json({msg: "product not found"})
        } else {
            return res.status(200).json({product});
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
})

/// new route for retrieving fproduct by category
productRouter.get('/api/products-by-category/:category', async(req, res) => {
    try {
        const {category} = req.params;
        const products = await Product.find({category});
        if (!products || products.length==0) {
            return res.status(404).json({msg: "Product not found"});
        } else {
            return res.status(200).json(products);
        }
    } catch (error) {
        res.status(500).json({error:e.message});
    }
})

module.exports = productRouter;