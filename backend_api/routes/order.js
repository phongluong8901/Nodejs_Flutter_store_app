const express = require('express');
const Order = require('../models/order');
require('dotenv').config();
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const {auth, vendorAuth} = require('../middleware/auth');

const orderRouter = express.Router();

orderRouter.post('/api/orders', auth, async(req, res) => {
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

//payment-intent
//Backend chỉ tạo hóa đơn chờ, còn việc thanh toán thực sự sẽ do Frontend và Stripe tự xử lý với nhau.
orderRouter.post('/api/payment-intent', async(req, res) => {
    try {
        const {amount, currency} = req.body;
        const paymentIntent = await stripe.paymentIntents.create({
            amount,
            currency
        });
        return res.status(200).json(paymentIntent);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

//payment api
orderRouter.post('/api/payment', async (req, res) => {
    try {
        const { orderId, paymentMethodId, currency = 'usd' } = req.body;
        
        // 1. Validate inputs
        if (!orderId || !paymentMethodId || !currency) {
            return res.status(400).json({ msg: "Missing required fields" });
        }
        
        // 2. Query order
        const order = await Order.findById(orderId);
        if (!order) {
            console.log("order not found", orderId);
            return res.status(404).json({ msg: "Order not found" });
        }
        
        // 3. Calculate amount
        const totalAmount = order.productPrice * order.quantity;
        const minimumAmount = 0.50;
        if (totalAmount < minimumAmount) {
            return res.status(400).json({ error: "Amount must be at least $0.50 USD" });
        }
        
        // Sửa lỗi chính tả: amountIncents (đã thêm chữ o)
        const amountIncents = Math.round(totalAmount * 100); 
        
        // 4. Create and Confirm Payment Intent
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amountIncents,
            currency: currency,
            payment_method: paymentMethodId,
            confirm: true, // Xác nhận thanh toán luôn bằng Payment Method gửi lên
            // Cần có return_url phòng trường hợp thẻ yêu cầu xác thực OTP/3D Secure
            return_url: 'https://your-website.com/payment-confirm', 
            automatic_payment_methods: {
                enabled: true,
                allow_redirects: 'always' // Cho phép chuyển hướng nếu cần xác thực OTP
            }
        });
        
        // 5. Response về frontend
        return res.json({
            status: "success", 
            paymentIntentId: paymentIntent.id, 
            clientSecret: paymentIntent.client_secret, // Cực kỳ quan trọng để frontend check trạng thái nếu bị redirect
            amount: paymentIntent.amount / 100,
            currency: paymentIntent.currency, // Sửa lỗi chính tả: curren -> currency
            paymentStatus: paymentIntent.status // Trả về trạng thái (succeeded, requires_action, v.v.)
        });

    } catch (error) {
        console.error("Stripe Error:", error);
        res.status(500).json({ error: error.message });
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
orderRouter.delete("/api/orders/:id", auth, async(req, res) => {
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
orderRouter.get('/api/orders/vendors/:vendorId', auth, vendorAuth, async(req, res) => {
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