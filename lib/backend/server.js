const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const Shop = require("./models/shop");
const User = require("./models/user");
const Worker = require("./models/worker");   // ← нэмэгдсэн

const app = express();
app.use(express.json());
app.use(cors());

mongoose.connect("mongodb://localhost:27017/Shop")
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));

/* ------------------- SHOP ROUTES (таны хуучин код) ------------------- */

// Get all shops
app.get("/shops", async (req, res) => {
  try {
    const shops = await Shop.find();
    res.json(shops);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single shop with products
app.get("/shops/:shopId", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });
    res.json(shop);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Insert new shop
app.post("/shops", async (req, res) => {
  try {
    const shop = new Shop(req.body);
    await shop.save();
    res.status(201).json(shop);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update shop
app.put("/shops/:id", async (req, res) => {
  try {
    const updatedShop = await Shop.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedShop) return res.status(404).json({ error: "Shop not found" });
    res.json(updatedShop);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete shop
app.delete("/shops/:id", async (req, res) => {
  try {
    const deletedShop = await Shop.findByIdAndDelete(req.params.id);
    if (!deletedShop) return res.status(404).json({ error: "Shop not found" });
    res.json({ message: "Shop deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Add product
app.post("/shops/:shopId/products", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });

    shop.products.push(req.body);
    await shop.save();
    res.status(201).json(shop);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update product
app.put("/shops/:shopId/products/:productId", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });

    const product = shop.products.id(req.params.productId);
    if (!product) return res.status(404).json({ error: "Product not found" });

    Object.assign(product, req.body);
    await shop.save();
    res.json(shop);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete product
app.delete("/shops/:shopId/products/:productId", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });

    shop.products.id(req.params.productId).remove();
    await shop.save();
    res.json(shop);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});



/* ------------------- WORKER ROUTES (шинээр нэмэгдсэн) ------------------- */

// Get all workers
app.get("/workers", async (req, res) => {
  try {
    const workers = await Worker.find().sort({ createdAt: -1 });
    res.json(workers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get one worker
app.get("/workers/:id", async (req, res) => {
  try {
    const worker = await Worker.findById(req.params.id);
    if (!worker) return res.status(404).json({ error: "Worker not found" });
    res.json(worker);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add new worker
app.post("/workers", async (req, res) => {
  try {
    const worker = new Worker(req.body);
    await worker.save();
    res.status(201).json(worker);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update worker
app.put("/workers/:id", async (req, res) => {
  try {
    const updated = await Worker.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!updated) return res.status(404).json({ error: "Worker not found" });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete worker
app.delete("/workers/:id", async (req, res) => {
  try {
    const deleted = await Worker.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ error: "Worker not found" });
    res.json({ message: "Worker deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
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