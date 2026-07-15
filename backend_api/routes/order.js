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

// get route for fetching order by buyer ID
orderRouter.get('/api/orders/:buyerId', async(req, res) => {
    try {
        //extract the buyerid from the request parameters
        const {buyerId} = req.params;
        //find all orders in the databse  that match the buyerid
        const orders = await Order.find({buyerId});
        //if no order arefound, return a 404 status with a message
        if(orders.length===0) {
            return res.status(404).json({msg: "No orders found for this buyerId"});
        }
        //if orders are found, return them with a 200 status code
        return res.status(200).json(orders);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});

module.exports = orderRouter;