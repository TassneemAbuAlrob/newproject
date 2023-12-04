const express = require("express");
const app = express();
const port = 3000 || process.env.PORT;
const cors = require("cors");
const bodyParser = require("body-parser");
const userRouter = require("./routes/userRoute");
const postRouter = require("./routes/postRoute");
const likeRouter = require("./routes/likeRoute");
const commentRouter = require("./routes/commentRoute");
const suggRouter = require("./routes/suggRoute");
const age = require("./routes/age_router");
const category = require("./routes/category_router");
const chat = require("./routes/chat_route");
const manager = require("./routes/manager_route");
const quiz = require("./routes/quiz_route");
const story = require("./routes/story_router");
const video = require("./routes/video_router");

const mongoose = require("mongoose");
mongoose.connect(
  "mongodb+srv://admin:admin@brainybuddiesdb.coiiev2.mongodb.net/?retryWrites=true&w=majority",
  { useNewUrlParser: true, useUnifiedTopology: true }
);
app.use(cors());

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.text());
app.use(bodyParser.raw());

app.use("/uploads", express.static("uploads"));

app.use(userRouter);
app.use(postRouter);
app.use(likeRouter);
app.use(commentRouter);
app.use(suggRouter);

app.use(age);
app.use(category);
app.use(chat);
app.use(manager);
app.use(quiz);
app.use(story);
app.use(video);

app.listen(port, () => {
  console.log("port running on " + port);
});
