const express = require('express'); //import module
const mongoose = require('mongoose');

const helloRoute = require('./routes/hello');
const authRouter = require('./routes/auth');

const PORT = 3000; //defind port number the server will listen on

//create an instance of an exprss application
//because it give us the starting point
const app = express();
//mongodb string
const DB = "mongodb+srv://phong:phong123@storedb.if70iek.mongodb.net/?appName=storeDB";

// app.get("/hello", (req, res) => {
//     res.send('Halo');
// })

//middleware - toregister routes or to mount routes
app.use(helloRoute);
app.use(express.json());
app.use(authRouter);

mongoose.connect(DB).then(()=> {
    console.log('mongodb Connected')
});

//start the server and listen on the specified port
app.listen(PORT, "0.0.0.0", function() {
    //log the number
    console.log(`server is running on port ${PORT}`);
})
