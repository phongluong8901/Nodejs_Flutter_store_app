const express = require('express');
const subCategory = require('../models/sub_category');

const subcategoryRouter = express.Router();

subcategoryRouter.post('/api/subcategories', async(req,res) => {
    try {
        const {categoryId, categoryName, image, subCategoryName} = req.body;
        const subcategory = new subCategory({categoryId, categoryName, image, subCategoryName});
        await subcategory.save()
        res.status(201).send(subcategory);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

subcategoryRouter.get('/api/category/:categoryName/subcategories', async(req,res) => {
    try {
        // extract the categoryName from the request Url using Destructuring
    const {categoryName} = req.params;
    const subcategories = await subCategory.find({categoryName:categoryName});

    //check ig any subcategories were found
    if(!subcategories || subcategories.length == 0) {
        //if no subcategories are found, response with status code 404 error
        return res.status(404).json({msg: "subcategories not found"})
    } else {
        return res.status(200).json(subcategories);
    }
    } catch (error) {
        res.status(500).json({error: error.message});   
    }
})

module.exports = subcategoryRouter;