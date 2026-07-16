const express = require('express');
const User = require('../models/user');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');


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

// signin api endpoint
authRouter.post('/api/signin', async(req,res) => {
    try {
        const {email, password} = req.body;
        const findUser = await User.findOne({email});
        if(!findUser) {
            return res.status(400).json({msg: "User noi found with this email"});
        } else {
           const isMatch = await bcrypt.compare(password, findUser.password);
           if(!isMatch) {
                return res.status(400).json({msg:'Incorrect Password'});
           } else {
                const token = jwt.sign({id:findUser._id}, "passwordKey");

                //remove sensitive information
                const {password, ...userWithoutPassword} = findUser._doc;

                //send the response
                res.json({token, user: userWithoutPassword});
           }
        }
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});

//route for updating user's state, city and localitu
authRouter.put('/api/users/:id', async(req, res) => {
    try {
        //extrat the 'id' parameter from the reuqest URL
        const {id} = req.params;
        //extract the "state", "city", "locality" fields from the request body
        const {state, city, locality} = req.body;
        //find the user by their ID and update the state, city and locality  fields
        //the {new:true} option ensures the updates document is returned
        const updateUser = await User.findByIdAndUpdate(
            id, 
            {state, city, locality},
            {new: true},
        );
        //if no user is found, return  404 page not found status with an error messasge
        if(!updateUser) {
            return res.status(404).json({error: "User not found"});
        }
        return res.status(200).json(updateUser);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

//fetch all users(exclude password)
authRouter.get('/api/users', async(req,res) => {
    try {
        const users = await User.find().select('-password'); //exclude password field
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

module.exports = authRouter;