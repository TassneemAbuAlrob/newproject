const express = require("express");
const Suggestion = require("../models/suggModel");
const router = express.Router();

router.post("/addSuggestion/:email", async (req, res) => {
  try {
    const { feedbackText, feedbackValue, suggText } = req.body;
    const email = req.params.email;
    if (!email || !feedbackText || !feedbackValue) {
      return res.status(400).json({ error: "Missing required parameters" });
    }

    const newSuggestion = new Suggestion({
      email,
      feedbackText,
      feedbackValue,
      suggText,
    });

    await newSuggestion.save();

    return res.status(200).json({ message: "Suggestion added successfully" });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal Server Error" });
  }
});
module.exports = router;
