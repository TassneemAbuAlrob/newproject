const mongoose = require("mongoose");

const postSchema = new mongoose.Schema({
  Textcontent: String,

  imagecontent: String,

  date: Date,
  email: String,
});

module.exports = mongoose.model("Post", postSchema);
