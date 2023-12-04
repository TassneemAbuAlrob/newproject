const mongoose = require("mongoose");
const CommentModel = require("./commentModel");

const VideoSchema = new mongoose.Schema({
  link: {
    type: String,
    required: true,
  },

  title: {
    type: String,
    required: true,
  },

  description: {
    type: String,
  },

  publish_date: {
    type: String,
    required: true,
  },

  publisher: {
    type: String,
    required: true,
  },

  views: {
    type: Number,
    default: 0,
  },

  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Category",
  },

  age: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Age",
  },

  interactions: {
    type: [String],
    default: [],
  },

  comments: {
    type: [String],
    default: [],
  },
});

const VideoModel = mongoose.model("Video", VideoSchema);

module.exports = VideoModel;
