const express = require('express');
const Order = require('../models/order');

const orderRouter = express.Router();

orderRouter.post('/api/orders', async(req, res) => {
    try {
        const {fullName, email, state, city, locality, productName, productPrice, quantity, category, images, vendorId, buyerId} = req.body;
        // const createdAt = new Date().getMilliseconds // get current date

        const createdAt = Date.now();

        //create new order instance with the extracted field
        const order = new Order({
            fullName, email, state, city, locality, productName, productPrice, quantity, category, images, vendorId, buyerId, createdAt
        });
        await order.save();
        return res.status(201).json(order);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});

module.exports = orderRouter;