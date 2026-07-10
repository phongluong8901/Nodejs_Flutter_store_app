const express = require('express');
const User = require('../models/user');
const bcrypt = require('bcryptjs');

// 1. Phải khai báo authRouter trước
const authRouter = express.Router();

// 2. Sau đó mới dùng authRouter.post(...)
authRouter.post('/api/signup', async (req, res) => {
    try {
        const {fullName, email, password} = req.body;

        const existingEmail = await User.findOne({email});
        if(existingEmail) {
            return res.status(400).json({msg: "user with same email already exist"});
        } else {
            //Generate a salt with a cost factor of 10
            const salt = await bcrypt.genSalt(10)
            //hash the password using the generated salt
            const hashedPassword = await bcrypt.hash(password, salt);
            // Sửa lỗi chính tả từ fullbame thành fullName
            const user = new User({fullName, email, password: hashedPassword});
            await user.save();
            res.json({user});
        }
    } catch (error) {
        // Sửa lỗi chính tả từ errror thành error và e thành error
        res.status(500).json({error: error.message});
    }
});

module.exports = authRouter;