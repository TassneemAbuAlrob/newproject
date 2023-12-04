const express = require('express')
const router = express.Router()

const multer = require('multer')
const moment = require('moment');
const Video = require('../models/video')
// Set up multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        // Set the destination folder where files will be saved
        cb(null, 'public/videos/'); // Create a folder named 'uploads' in your project root
    },
    filename: function (req, file, cb) {
        // Set the file name with original name + timestamp to make it unique
        cb(null, moment() + '_' + file.originalname);
    }
});

const upload = multer({ storage: storage });


router.post('/videos',upload.single('video'),async (req, res) => {
    try{
        let {
            title,
            description
        } = req.body

        if(title == undefined || description == undefined){
            return res.status(400).json({
                success: false,
                message: 'please provide a title and description'
            })
        }

        let publish_date = moment().format('YYYY-MM-DD HH:mm:ss')
        const link = process.env.APP_URL + req.file.path

        const video = await Video.create({
            title: title,
            description: description,
            link: link,
            publish_date: publish_date,
            publisher: 'admin'
        })

        return res.status(200).json({
            success: true,
            video: video
        })
    }catch(e){
        return res.status(500).json(e.message)
    }
})

router.get('/videos', async (req, res) => {
    let videos = await Video.find()
    return res.status(200).json(videos)
});

router.get('/videos/count', async function(req, res){
    try{
        let count = await Video.count()
        return res.status(200).json(count)
    }catch(err){
        return res.status(500).json(err.message)
    }
})

router.get('/videos/:id', async (req, res) => {
    try{
        const { id } = req.params
        let video = await Video.findOne({ _id: id })
        if(!video) return res.status(404).json({ message: 'video not found' })


        return res.status(200).json(video)

    }catch(e){
        return res.status(500).json({
            success: false,
            message: e.message
        })
    }
})

router.delete('/videos/:id/', async (req, res) => {
    await Video.deleteOne({ _id: req.params.id})
    return res.status(200).json({
        success: true,
        message: 'Video deleted successfully'
    })
})


router.put('/videos/:id', async (req, res) => {
    try{
        const {
            title,
            description
        } = req.body

        if(!title || !description){
            return res.status(400).json({
                success: false,
                message: 'Invalid title or description provided'
            })
        }

        let updateStatus = await Video.updateOne({
            _id: req.params.id,
        },{title,description})

        if(updateStatus) {
            return res.status(200).json({success: updateStatus })
        }
    }catch(err){
        return res.status(500).json({ error: err.message })
    }
})


router.get('/videos/count',async (req, res) => {
    let count = await Video.count()
    return res.status(200).json(count)
})

module.exports = router