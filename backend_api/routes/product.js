const express = require('express');
const productRouter = express.Router(); // 1. KHAI BÁO BIẾN NÀY ĐẦU TIÊN
const Product = require('../models/product'); // 2. Import model (chỉ cần 1 lần)

productRouter.post('/api/add-product', async (req, res) => {
    try {
        const { productName, productPrice, quantity, description, category, subCategory, images } = req.body;
        
        // 3. Đổi tên biến mới thành 'newProduct' để tránh trùng với tên import 'Product'
        const newProduct = new Product({
            productName, 
            productPrice, 
            quantity, 
            description, 
            category, 
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

module.exports = productRouter;