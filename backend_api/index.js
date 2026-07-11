const express = require('express'); //import module
const mongoose = require('mongoose');
const cors = require('cors');

const authRouter = require('./routes/auth');
const bannerRouter = require('./routes/banner')
const categoryRouter = require('./routes/category');
const subcategoryRouter = require('./routes/sub_category');
const productRouter = require('./routes/product');
const productReviewRouter = require('./routes/product_review');

const PORT = 3000; //defind port number the server will listen on

//create an instance of an exprss application
//because it give us the starting point
const app = express();
//mongodb string
const DB = "mongodb+srv://phong:phong123@storedb.if70iek.mongodb.net/?appName=storeDB";

app.use(cors({
    origin: '*', 
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Origin', 'Content-Type', 'Accept', 'Authorization']
}));

//middleware - toregister routes or to mount routes
app.use(express.json());
app.use(authRouter);
app.use(bannerRouter);
app.use(categoryRouter);
app.use(subcategoryRouter);
app.use(productRouter);
app.use(productReviewRouter);

mongoose.connect(DB).then(()=> {
    console.log('mongodb Connected')
});

//start the server and listen on the specified port
app.listen(PORT, "0.0.0.0", function() {
    //log the number
    console.log(`server is running on port ${PORT}`);
})
