const express = require('express');
const router = express.Router();
const Story = require('../models/story'); // Import your Story model

const multer = require('multer')
const moment = require('moment');
const path = require('path');

// Set up multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      if(file.mimetype == 'application/octet-stream' && path.extname(file.originalname) == '.pdf'){
        cb(null, 'public/files/stories/')
      }else{
        cb(null, 'public/images/stories/'); // Create a folder named 'uploads' in your project root
      }
    },
    filename: function (req, file, cb) {
        // Set the file name with original name + timestamp to make it unique
        cb(null, Date.now() + '_' + file.originalname);
    }
});

const upload = multer({ storage: storage });


// Get all stories
router.get('/stories', async (req, res) => {
  try {
    const stories = await Story.find();
    console.log(stories);
    res.status(200).json(stories);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

router.get('/stories/count', async (req, res) => {
  let count = await Story.count()
  return res.status(200).json(count)
})

// Create a new story
router.post('/stories',upload.any(), async (req, res) => {
  const { content,title,publisher } = req.body

  const publish_date = moment().format('YYYY-MM-DD HH:mm:ss')

  let image = process.env.APP_URL + req.files[0].path
  let file = process.env.APP_URL + req.files[1].path


  const newStory = new Story({
    title: title,
    pdf: file,
    image: image,
    publish_date: publish_date,
    publisher: publisher
  });
  try {
    const savedStory = await newStory.save();
    res.status(200).json(savedStory);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get a specific story by ID
router.get('/stories/:id', async (req, res) => {
  try {
    const story = await Story.findById(req.params.id);
    if (!story) {
      return res.status(404).json({ message: 'Story not found' });
    }
    res.json(story);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Update a story by ID
router.put('/stories/:id', async (req, res) => {
  try {
    const updatedStory = await Story.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedStory) {
      return res.status(404).json({ message: 'Story not found' });
    }
    res.json(updatedStory);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete a story by ID
router.delete('/stories/:id', async (req, res) => {
  try {
    const deletedStory = await Story.findByIdAndRemove(req.params.id);
    if (!deletedStory) {
      return res.status(404).json({ message: 'Story not found' });
    }
    res.json({ message: 'Story deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
