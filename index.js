const express = require("express");
const app = express();
const port = 3000 || process.env.PORT;
const cors = require("cors");
const bodyParser = require("body-parser");
const userRouter = require("./routes/userRoute");
const postRouter = require("./routes/postRoute");
const likeRouter = require("./routes/likeRoute");
const commentRouter = require("./routes/commentRoute");

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

app.listen(port, () => {
  console.log("port running on " + port);
});
