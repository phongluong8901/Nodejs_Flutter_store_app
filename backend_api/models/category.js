const mongoose = require('mongoose');
const categorySchema = mongoose.Schema({
    name: {
        type: String,
        requierd: true,
    },

    image: {
        type: String,
        required: true,
    },

    banner: {
        type: String,
    }
});

const Category = mongoose.model('Category', categorySchema);
module.exports = Category;