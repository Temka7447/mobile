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

const JWT_SECRET = process.env.JWT_SECRET || "your_secret_key";

// MongoDB connection
mongoose.connect("mongodb://localhost:27017/Shop")
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));

/* ===================== SHOP ROUTES ===================== */
app.get("/shops", async (req, res) => {
  try {
    const shops = await Shop.find();
    res.json({ success: true, message: "Shops fetched", shops });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

app.post("/shops", async (req, res) => {
  try {
    const shop = new Shop(req.body);
    await shop.save();
    res.status(201).json({ success: true, message: "Shop saved", shop });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
});

app.get("/shops/:shopId/products", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ success: false, message: "Shop not found" });

    const products = shop.products.map(p => ({
      ...p.toObject(),
      shopId: shop._id.toString(),
      shopName: shop.name ?? ''
    }));
    res.json({ success: true, message: "Products fetched", products });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* ===================== USER ROUTES ===================== */

// Register user
app.post("/users", async (req, res) => {
  try {
    const { name, lastName, phone, password, email } = req.body;

    if (!name || !lastName || !phone || !password) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 8 characters, include uppercase, lowercase, number, and special character"
      });
    }

    const existingUser = await User.findOne({ phone });
    if (existingUser) return res.status(400).json({ success: false, message: "Phone already registered" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ name, lastName, phone, email: email ?? '', password: hashedPassword });
    await user.save();

    res.status(201).json({
      success: true,
      message: "User created successfully",
      user: {
        id: user._id.toString(),
        name: user.name ?? '',
        lastName: user.lastName ?? '',
        phone: user.phone ?? '',
        email: user.email ?? '',
        role: user.role ?? 'user'
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Login
app.post("/login", async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return res.status(400).json({ success: false, message: "Phone and password are required" });
    }

    const user = await User.findOne({ phone });
    if (!user) return res.status(401).json({ success: false, message: "Phone not found" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ success: false, message: "Wrong password" });

    const token = jwt.sign(
      { id: user._id.toString(), phone: user.phone, name: user.name, role: user.role || 'user' },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      success: true,
      message: "Login success",
      token: token,
      user: {
        id: user._id.toString(),
        name: user.name ?? '',
        lastName: user.lastName ?? '',
        phone: user.phone ?? '',
        email: user.email ?? '',
        role: user.role ?? 'user'
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// JWT middleware
const authMiddleware = (req, res, next) => {
  const header = req.headers["authorization"];
  const token = header ? header.split(" ")[1] : null;
  if (!token) return res.status(401).json({ success: false, message: "Access denied" });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ success: false, message: "Invalid token" });
  }
};

// Get logged-in user
app.get("/users/me", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user) return res.status(404).json({ success: false, message: "User not found" });
    res.json({
      success: true,
      message: "User fetched",
      user: {
        id: user._id.toString(),
        name: user.name ?? '',
        lastName: user.lastName ?? '',
        phone: user.phone ?? '',
        email: user.email ?? '',
        role: user.role ?? 'user'
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Update logged-in user
app.put("/users/me", authMiddleware, async (req, res) => {
  try {
    const { name, lastName, phone, email } = req.body;
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { name, lastName, phone, email },
      { new: true, runValidators: true }
    ).select("-password");

    if (!updatedUser) return res.status(404).json({ success: false, message: "User not found" });
    res.json({
      success: true,
      message: "User updated",
      user: {
        id: updatedUser._id.toString(),
        name: updatedUser.name ?? '',
        lastName: updatedUser.lastName ?? '',
        phone: updatedUser.phone ?? '',
        email: updatedUser.email ?? '',
        role: updatedUser.role ?? 'user'
      }
    });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));