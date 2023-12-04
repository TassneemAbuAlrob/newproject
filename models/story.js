const mongoose = require('mongoose');

const StorySchema = new mongoose.Schema({
    title:{
        type: String,
        required: true
    },

    category:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category'
    },

    age: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Age'
    },

    pdf: {
        type: String,
        required: true
    },

    image:{
        type: String,
        required: true
    },

    interactions:{
        type: [String],
        default: []
    },

    comments:{
        type: [String],
        default: [],
        ref: 'Comment'
    },

    publisher:{
        type: String,
        required: true,
    },

    views: {
        type: Number,
        default: 0
    },

    publish_date:{
        type: String,
        required: true
    }
})


const StoryModel = mongoose.model('Story', StorySchema)

module.exports = StoryModel