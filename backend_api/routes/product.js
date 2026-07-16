const express = require('express');
const productRouter = express.Router(); // 1. KHAI BÁO BIẾN NÀY ĐẦU TIÊN
const Product = require('../models/product'); // 2. Import model (chỉ cần 1 lần)
const {auth, vendorAuth} = require('../middleware/auth');

productRouter.post('/api/add-product', auth, vendorAuth, async (req, res) => {
    try {
        const { productName, productPrice, quantity, description, category, vendorId, fullName, subCategory, images } = req.body;
        
        // 3. Đổi tên biến mới thành 'newProduct' để tránh trùng với tên import 'Product'
        const newProduct = new Product({
            productName, 
            productPrice, 
            quantity, 
            description, 
            category, 
            vendorId,
            fullName,
            subCategory, 
            images
        });
        
        await newProduct.save();
        return res.status(201).json(newProduct);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

productRouter.get('/api/popular-products', async(req,res) => {
    try {
        const product = await Product.find({popular:true});
        if(!product || product.length == 0) {
            return res.status(404).json({msg: "product not found"})
        } else {
            return res.status(200).json({product});
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

/// new route for retrieving fproduct by category
productRouter.get('/api/products-by-category/:category', async(req, res) => {
    try {
        const {category} = req.params;
        const products = await Product.find({category});
        if (!products || products.length==0) {
            return res.status(404).json({msg: "Product not found"});
        } else {
            return res.status(200).json(products);
        }
    } catch (error) {
        res.status(500).json({error:error.message});
    }
});

//new route for retrieving related product by subcategory
productRouter.get('/api/related-products-by-subcategory/:productId', async(req,res) => {
    try {
        const {productId} = req.params;
        //first, find the product to get its subcategory
        const product = await Product.findById(productId);
        if(!product) {
            return res.status(404).json({msg: "Product not found"});
        } else {
            //find related produts base on the subcategory of the retrieved product
            const relatedProducts = await Product.find({
                subCategory: product.subCategory,
                _id: {$ne:productId} //exclude the current product
            });
            if(!relatedProducts || relatedProducts.length==0) {
                return res.status(404).json({msg: "NO related products found"});
            }

            return res.status(200).json(relatedProducts);
        }
    } catch (error) {
        res.status(500).json({error:error.message});
    }
});

//route for retrieving the top 10 highest-rated products
productRouter.get('/api/top-rated-products',async(req,res)=>{
  try {
    //fetch all products and sort them by avaragerating in decending order(higest rating)
    //sort product by averageRating, with -1 indicating decending
  const topRatedProducts =  await Product.find({}).sort({averageRating: -1}).limit(10);//limit the result to the top highest rated product

  //check if there are any top-rated products  returned
  if(!topRatedProducts||topRatedProducts.length==0){
    return res.status(404).json({msg:"No top-rated products  found"});
  }

  //return the top-rated product as a response 
  return res.status(200).json(topRatedProducts);
  } catch (e) {
    //handle any server errors that occure during the request
    return res.status(500).json({error:e.message});
  }
});

module.exports = productRouter;