const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const Shop = require("./models/shop");
const User = require("./models/User");

const app = express();
app.use(express.json());
app.use(cors());

// Use environment variable for JWT secret in production
const JWT_SECRET = process.env.JWT_SECRET || "your_secret_key";

// Connect to MongoDB
mongoose.connect("mongodb://localhost:27017/Shop")
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));

/* ===================== SHOP ROUTES ===================== */
app.get("/shops", async (req, res) => {
  try {
    const shops = await Shop.find();
    res.json(shops);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/shops", async (req, res) => {
  try {
    const shop = new Shop(req.body);
    await shop.save();
    res.status(201).json({ message: "Shop saved", shop });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.put("/shops/:id", async (req, res) => {
  try {
    const updatedShop = await Shop.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedShop) return res.status(404).json({ error: "Shop not found" });
    res.json({ message: "Shop updated", updatedShop });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.delete("/shops/:id", async (req, res) => {
  try {
    const deletedShop = await Shop.findByIdAndDelete(req.params.id);
    if (!deletedShop) return res.status(404).json({ error: "Shop not found" });
    res.json({ message: "Shop deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.get("/shops/:shopId/products", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });

    const products = shop.products.map(p => ({
      ...p.toObject(),
      shopId: shop._id,
      shopName: shop.name
    }));
    res.json(products);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ===================== USER ROUTES ===================== */
// Get all users
app.get("/users", async (req, res) => {
  try {
    const users = await User.find().select("-password"); // exclude password
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Register user
app.post("/users", async (req, res) => {
  try {
    const { name, lastName, phone, password } = req.body;
    if (!name || !lastName || !phone || !password) {
      return res.status(400).json({ error: "All fields are required" });
    }

    // Password validation
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({ 
        error: "Password must be at least 8 characters, include uppercase, lowercase, number, and special character"
      });
    }

    const existingUser = await User.findOne({ phone });
    if (existingUser) return res.status(400).json({ error: "Phone already registered" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ name, lastName, phone, password: hashedPassword });
    await user.save();

    res.status(201).json({ 
      message: "User created successfully", 
      user: { _id: user._id, name: user.name, lastName: user.lastName, phone: user.phone }
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Middleware to verify JWT
const authMiddleware = (req, res, next) => {
  const token = req.headers["authorization"]?.split(" ")[1]; // Bearer token
  if (!token) return res.status(401).json({ error: "Access denied" });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ error: "Invalid token" });
  }
};

// Get logged-in user
app.get("/users/me", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update user
app.put("/users/:id", async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(req.params.id, req.body, { new: true }).select("-password");
    if (!updatedUser) return res.status(404).json({ error: "User not found" });
    res.json({ message: "User updated", updatedUser });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete user
app.delete("/users/:id", async (req, res) => {
  try {
    const deletedUser = await User.findByIdAndDelete(req.params.id);
    if (!deletedUser) return res.status(404).json({ error: "User not found" });
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

/* ===================== LOGIN ===================== */
app.post("/login", async (req, res) => {
  const { phone, password } = req.body;
  try {
    const user = await User.findOne({ phone });
    if (!user) return res.status(404).json({ error: "Phone not found" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ error: "Wrong password" });

    const token = jwt.sign(
      { id: user._id, phone: user.phone, name: user.name },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      message: "Login success",
      token,
      user: { id: user._id, name: user.name, phone: user.phone }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
