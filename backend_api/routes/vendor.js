const express = require('express');
const Vendor = require('../models/vendor');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const vendorRouter = express.Router();

vendorRouter.post('/api/vendor/signup', async (req, res) => {
    try {
        const {fullName, email, password} = req.body;

        const existingEmail = await Vendor.findOne({email});
        if(existingEmail) {
            return res.status(400).json({msg: "vendor with same email already exist"});
        } else {
            //Generate a salt with a cost factor of 10
            const salt = await bcrypt.genSalt(10)
            //hash the password using the generated salt
            const hashedPassword = await bcrypt.hash(password, salt);
            // Sửa lỗi chính tả từ fullbame thành fullName
            const vendor = new Vendor({fullName, email, password: hashedPassword});
            await vendor.save();
            res.json({vendor});
        }
    } catch (error) {
        // Sửa lỗi chính tả từ errror thành error và e thành error
        res.status(500).json({error: error.message});
    }
});

vendorRouter.post('/api/vendor/signin', async(req,res) => {
    try {
        const {email, password} = req.body;
        const findVendor = await Vendor.findOne({email});
        if(!findVendor) {
            return res.status(400).json({msg: "vendor not found with this email"});
        } else {
           const isMatch = await bcrypt.compare(password, findVendor.password);
           if(!isMatch) {
                return res.status(400).json({msg:'Incorrect Password'});
           } else {
                const token = jwt.sign({id:findVendor._id}, "passwordKey");

                //remove sensitive information
                const {password, ...vendorWithoutPassword} = findVendor._doc;

                //send the response
                res.json({token, vendor: vendorWithoutPassword});
           }
        }
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});


module.exports = vendorRouter;