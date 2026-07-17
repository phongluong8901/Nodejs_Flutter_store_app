const jwt = require('jsonwebtoken');
const User = require('../models/user');
const Vendor = require('../models/vendor'); // 1. ĐÃ THÊM: Import model Vendor để không bị lỗi "Vendor is not defined"

//authentication middleware
//this middlware func checks if the user is authenticated

const auth = async(req, res, next) => {
    try {
        //extract the token the reques headers
        const token = req.header('x-auth-token');
        //if no token is provided, return 401(unauthorization) response with an error
        if(!token) return res.status(401).json({msg: 'No authentication token, authorization denied'});
        //verify the jwt token using the secret key
        const verified = jwt.verify(token, "passwordKey");
        //if the token verification failed, return401
        if(!verified) return res.status(401).json({msg: "Token verification  failed, authorization denied"});
        //find the normal user or vendor in the datebase using the id store in the token payload
        const user = await User.findById(verified.id) || await Vendor.findById(verified.id);

        if(!user) return res.status(401).json({msg:"User or Vendor not  found,authorization denied"});

        //attact the authenticated user (whether a normal user  or a vendor ) to  the request objects
        //this makes the user's data available to any subsequent middleware  or route handlers

        req.user = user;
        //also attact the toke to the request object  in case is needed later

        req.token = token;

        //proceed to the next middleware or route handler
        next();
    } catch (e) { // 2. ĐÃ SỬA: Đổi "error" thành "e" để khớp với "e.message" ở dưới
         res.status(500).json({error:e.message});  
    }
};

//vendor authentication middleware
// this middleware ensure that the user making the request is a vendor
//it shoud be used for routes that only vendor can access

const vendorAuth = (req,res,next)=>{
 try {
   //check if the user making the request is a vendor (by checking the "role"property)
   if(!req.user.role || req.user.role!=="vendor"){
    //if the user is not a vendor , return 403(Forbidden) respone with an error message
    return res.status(403).json({msg:"Access denied, only vendors are allowed"});
  }

  //if the user is a vendor, procceed to the next middleware  or route handler
  next();
 } catch (e) {
  return res.status(500).json({error:e.message});
 }
};

module.exports = {auth, vendorAuth};