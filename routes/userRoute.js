const express = require("express");
const User = require("../models/userModel");
const router = express.Router();
const fileUpload = require("express-fileupload");
router.use(fileUpload());
const { format } = require("date-fns");

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log(req.body);

    let user = await User.findOne({ email: email });
    if (!user) {
      return res.status(404).send("User not found");
    }

    let userPassword = user.password;
    if (userPassword != password) {
      return res.status(400).send("Password mismatch");
    }

    return res.status(200).send("User successfully authenticated");
  } catch (err) {
    return res.status(500).send(err.message);
  }
});

router.post("/signup", async (req, res) => {
  try {
    const existingUser = await User.findOne({ email: req.body.email });
    if (existingUser) {
      return res.status(409).json({ message: "Email is already in use" });
    }

    if (req.body.password !== req.body.confirmPassword) {
      return res.status(400).json({ message: "Passwords do not match" });
    }

    const newUser = new User({
      email: req.body.email,
      password: req.body.password,
      name: req.body.name,
      profileType: req.body.profileType,
      phoneNumber: req.body.phoneNumber,
      profilePicture: req.body.profilePicture,
    });

    await newUser.save();

    console.log("User registered:", newUser);
    res.status(201).json(newUser);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
});

//fetch data on child profile page
router.get("/showchildprofile/:email", async (req, res) => {
  const userEmail = req.params.email;

  console.log("Requested email:", userEmail);

  try {
    let user = await User.findOne({ email: userEmail });

    console.log("Database query result:", user);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

//edit child profile information:

router.post("/editchildprofile/:email", async (req, res) => {
  const userEmail = req.params.email;
  const { name, email, phoneNumber } = req.body;
  const profilePicture = req.files ? req.files.profilePicture : null;

  try {
    const user = await User.findOne({ email: userEmail });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Optional: Add data validation here

    user.name = name;
    user.email = email;
    user.phoneNumber = phoneNumber;

    if (profilePicture) {
      const uploadedFile = profilePicture;
      const newFileName = `${Date.now()}_${uploadedFile.name}`;
      await uploadedFile.mv(`./uploads/${newFileName}`);

      user.profilePicture = newFileName;
    }

    await user.save();

    res.json({ message: "Child information updated successfully" });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ error: "An error occurred while updating Child information" });
  }
});

//list of users
router.get("/ListOfUsers/:email", async (req, res) => {
  const { email } = req.params;
  try {
    const users = await User.find(
      { email: { $ne: email } },
      "name email phoneNumber profileType profilePicture"
    );

    const usersWithCompleteData = users.map((user) => ({
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      profileType: user.profileType,
      profilePicture: `http://192.168.1.112:3000/uploads/${user.profilePicture}`,
    }));

    res.json(usersWithCompleteData);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "An error occurred while fetching users" });
  }
});

//follow
router.post("/usersfollow/:email", async (req, res) => {
  const userEmail = req.params.email;
  const { followUserEmail, follow } = req.body;

  try {
    const user = await User.findOne({ email: userEmail });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const followUser = await User.findOne({ email: followUserEmail });
    if (!followUser) {
      return res
        .status(404)
        .json({ error: "User to follow/unfollow not found" });
    }

    if (follow) {
      if (!user.following.includes(followUser._id)) {
        user.following.push(followUser._id);
      }
      if (!followUser.followers.includes(user._id)) {
        followUser.followers.push(user._id);
      }
    } else {
      user.following = user.following.filter(
        (id) => id.toString() !== followUser._id.toString()
      );
      followUser.followers = followUser.followers.filter(
        (id) => id.toString() !== user._id.toString()
      );
    }

    await user.save();
    await followUser.save();

    res.status(200).json({ message: "Operation successful" });
  } catch (error) {
    res.status(500).json({ error: "Could not follow/unfollow user" });
  }
});

//unfollow
router.delete("/usersunfollow/:email", async (req, res) => {
  const userEmail = req.params.email;
  const { followUserEmail } = req.body;

  try {
    const user = await User.findOne({ email: userEmail });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const followUser = await User.findOne({ email: followUserEmail });
    if (!followUser) {
      return res.status(404).json({ error: "User to unfollow not found" });
    }

    // Remove followUser's ID from user's following
    user.following = user.following.filter(
      (id) => id.toString() !== followUser._id.toString()
    );

    // Remove user's ID from followUser's followers
    followUser.followers = followUser.followers.filter(
      (id) => id.toString() !== user._id.toString()
    );

    // Save changes to both user and followUser
    await user.save();
    await followUser.save();

    res.status(200).json({ message: "Unfollow successful" });
  } catch (error) {
    res.status(500).json({ error: "Could not unfollow user" });
  }
});

//list of followers

router.get("/followers/:email", async (req, res) => {
  const userEmail = req.params.email;

  try {
    const user = await User.findOne({ email: userEmail });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const followers = await User.find({ _id: { $in: user.followers } });

    const followerList = followers.map((follower) => ({
      name: follower.name,
      email: follower.email,
      phoneNumber: follower.phoneNumber,
      profilePicture: `http://192.168.1.112:3000/uploads/${follower.profilePicture}`,
    }));

    res.status(200).json(followerList);
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ error: "An error occurred while fetching followers" });
  }
});

// View Following Endpoint
router.get("/following/:email", async (req, res) => {
  const userEmail = req.params.email;

  try {
    // Find the user based on the provided email
    const user = await User.findOne({ email: userEmail });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const following = await User.find({ _id: { $in: user.following } });

    const followingList = following.map((followedUser) => ({
      name: followedUser.name,
      email: followedUser.email,
      phoneNumber: followedUser.phoneNumber,

      profilePicture: `http://192.168.1.112:3000/uploads/${followedUser.profilePicture}`,
    }));

    res.status(200).json(followingList);
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ error: "An error occurred while fetching following users" });
  }
});

//parentprofile

router.get("/showprentprofile/:email", async (req, res) => {
  const userEmail = req.params.email;

  console.log("Requested email:", userEmail);

  try {
    let user = await User.findOne({ email: userEmail });

    console.log("Database query result:", user);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

//edit perant profile information:

router.post("/editparentprofile/:email", async (req, res) => {
  const userEmail = req.params.email;
  const { name, email, phoneNumber } = req.body;
  const profilePicture = req.files ? req.files.profilePicture : null;

  try {
    const user = await User.findOne({ email: userEmail });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Optional: Add data validation here

    user.name = name;
    user.email = email;
    user.phoneNumber = phoneNumber;

    if (profilePicture) {
      const uploadedFile = profilePicture;
      const newFileName = `${Date.now()}_${uploadedFile.name}`;
      await uploadedFile.mv(`./uploads/${newFileName}`);

      user.profilePicture = newFileName;
    }

    await user.save();

    res.json({ message: "Child information updated successfully" });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ error: "An error occurred while updating Child information" });
  }
});

//add children

router.post("/addChild/:parentemail", async (req, res) => {
  try {
    const existingUser = await User.findOne({ email: req.body.email });
    if (existingUser) {
      return res.status(409).json({ message: "Email is already in use" });
    }

    if (req.body.password !== req.body.confirmPassword) {
      return res.status(400).json({ message: "Passwords do not match" });
    }

    const newUser = new User({
      email: req.body.email,
      password: req.body.password,
      name: req.body.name,
      profileType: "child",
      phoneNumber: req.body.phoneNumber,
      profilePicture: req.body.profilePicture,
      parentEmail: req.params.parentemail,
    });

    await newUser.save();

    console.log("child add successfully:", newUser);
    res.status(201).json(newUser);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
});

//number of children
const countChildUsers = async (parentEmail) => {
  try {
    const count = await User.countDocuments({ parentEmail: parentEmail });
    return count;
  } catch (error) {
    console.error(error);
    throw new Error("Error counting child users");
  }
};
router.get("/countChildUsers/:parentemail", async (req, res) => {
  try {
    const parentEmail = req.params.parentemail;
    const userCount = await countChildUsers(parentEmail);

    res.status(200).json({ count: userCount });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// Fetch children users based on parent's email
router.get("/fetchChildren/:parentemail", async (req, res) => {
  const parentEmail = req.params.parentemail;

  try {
    const parentUser = await User.findOne({ email: parentEmail });

    if (!parentUser) {
      return res.status(404).json({ error: "Parent user not found" });
    }

    const children = await User.find({
      parentEmail: parentEmail,
      profileType: "child",
    });

    const childrenList = children.map((child) => ({
      name: child.name,
      email: child.email,
      profilePicture: `http://192.168.1.112:3000/uploads/${child.profilePicture}`,
    }));

    res.status(200).json(childrenList);
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ error: "An error occurred while fetching children users" });
  }
});

module.exports = router;
