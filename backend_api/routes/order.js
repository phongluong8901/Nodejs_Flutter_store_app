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

//delete router for deleting a specific order by_id
orderRouter.delete("/api/orders/:id", async(req, res) => {
    try {
        //extract the id from the rwequest parameter
        const {id} = req.params;
        //find tand delete the or from the data base using extract _id
        const deleteOrder = await Order.findByIdAndDelete(id);
        //check if an order was found and deleted
        if(!deleteOrder) {
            //if no order was found the provided _id return 404
            return res.status(404).json({msg: "Order not found"});
        } else {
            //if the orderwas successfully deleted, return 200 status with a seuccess message
            return res.status(200).json({msg: "Order was deleted successfully"});
        }
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});

// get route for fetching order by vendor ID
orderRouter.get('/api/orders/vendors/:vendorId', async(req, res) => {
    try {
        //extract the vendorId from the request parameters
        const {vendorId} = req.params;
        //find all orders in the databse  that match the vendorId
        const orders = await Order.find({vendorId});
        //if no order arefound, return a 404 status with a message
        if(orders.length===0) {
            return res.status(404).json({msg: "No orders found for this vendorId"});
        }
        //if orders are found, return them with a 200 status code
        return res.status(200).json(orders);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});

orderRouter.patch('/api/orders/:id/delivered', async(req,res) => {
    try {
        const {id} = req.params;
        const updatedOrder = await Order.findByIdAndUpdate(
            id,
            {delivered: true, processing: false},
            {new: true},
        );
        if(!updatedOrder) {
            return res.status(404).json({msg: "Order not found"});
        } else {
            return res.status(200).json(updatedOrder);
        }
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

orderRouter.patch('/api/orders/:id/processing', async(req,res) => {
    try {
        const {id} = req.params;
        const updatedOrder = await Order.findByIdAndUpdate(
            id,
            {delivered: false, processing: false},
            {new: true},
        );
        if(!updatedOrder) {
            return res.status(404).json({msg: "Order not found"});
        } else {
            return res.status(200).json(updatedOrder);
        }
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

orderRouter.get('/api/orders', async(req, res) => {
    try {
        const orders = await Order.find();
        res.status(200).send({orders});
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

module.exports = orderRouter;