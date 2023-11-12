const express = require("express");
const fileUpload = require("express-fileupload");
const Post = require("../models/postModel");
const router = express.Router();

const { format } = require("date-fns");

router.post("/addPost/:email", async (req, res) => {
  try {
    const { Textcontent } = req.body;
    const email = req.params.email;

    if (req.files && req.files.img) {
      const img = req.files.img;
      const imgName = img.name;

      img.mv(`./uploads/${imgName}`, (err) => {
        if (err) {
          console.error(err);
          res.status(500).json({ error: "Error uploading image" });
          return;
        }

        const post = new Post({
          Textcontent,
          imagecontent: imgName, // Store the image filename in the "imagecontent" field
          date: new Date(),
          email,
        });

        post
          .save()
          .then((savedPost) => {
            res.status(200).json({ message: "Post created successfully" });
          })
          .catch((error) => {
            console.error(error);
            res.status(500).json({ error: "Error saving the post" });
          });
      });
    } else if (Textcontent) {
      const post = new Post({
        Textcontent,
        date: new Date(),
        email,
      });

      post
        .save()
        .then((savedPost) => {
          res.status(200).json({ message: "Text Post created successfully" });
        })
        .catch((error) => {
          console.error(error);
          res.status(500).json({ error: "Error saving the text post" });
        });
    }
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ error: "An error occurred while creating the post" });
  }
});

router.get("/getPosts/:email", async (req, res) => {
  const userEmail = req.params.email;

  try {
    const posts = await Post.find({ email: userEmail }).sort({ date: -1 });

    const formattedPosts = posts.map((post) => ({
      _id: post._id.toString(), // Convert _id to string
      Textcontent: post.Textcontent,
      email: post.email,
      date: post.date,
      imagecontent: post.imagecontent,
    }));

    res.status(200).json(formattedPosts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error fetching posts" });
  }
});

//delete post
router.delete("/deletePost/:postId", async (req, res) => {
  const postId = req.params.postId;

  try {
    const result = await Post.deleteOne({ _id: postId });

    if (result.deletedCount === 1) {
      res.status(200).json({ message: "Post deleted successfully" });
    } else {
      res.status(404).json({ message: "Post not found for deletion" });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error deleting the post" });
  }
});
router.use(fileUpload());

module.exports = router;
