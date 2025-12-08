const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const Shop = require("./models/shop");
const User = require("./models/user");
const Worker = require("./models/worker");

const app = express();
app.use(express.json());
app.use(cors());

// IMPORTANT: define JWT secret (use env var in production)
const JWT_SECRET = process.env.JWT_SECRET || "your_secret_key_here";

// MongoDB connection
mongoose.connect("mongodb://localhost:27017/Shop")
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));

/**
 * Helper: normalize location object coming from client request
 * Accepts either:
 * - location: { address, lat, lng }
 * - address, lat, lng at root
 * Returns either undefined (if no location provided) or object { address, lat, lng }
 */
function parseLocationFromBody(body) {
  if (!body) return undefined;

  // prefer nested location
  const loc = body.location;
  let address = "";
  let lat = null;
  let lng = null;
  let hasLocation = false;

  if (loc && typeof loc === "object") {
    if (typeof loc.address === "string") { address = loc.address; hasLocation = true; }
    if (loc.lat !== undefined && loc.lat !== null && !Number.isNaN(Number(loc.lat))) { lat = Number(loc.lat); hasLocation = true; }
    if (loc.lng !== undefined && loc.lng !== null && !Number.isNaN(Number(loc.lng))) { lng = Number(loc.lng); hasLocation = true; }
  } else {
    // fallback to flat fields
    if (typeof body.address === "string") { address = body.address; hasLocation = true; }
    if (body.lat !== undefined && body.lat !== null && !Number.isNaN(Number(body.lat))) { lat = Number(body.lat); hasLocation = true; }
    if (body.lng !== undefined && body.lng !== null && !Number.isNaN(Number(body.lng))) { lng = Number(body.lng); hasLocation = true; }
  }

  if (!hasLocation) return undefined;
  return { address, lat, lng };
}

/**
 * Helper: ensure shop object returned to client always contains a location key
 */
function sanitizeShopDoc(doc) {
  if (!doc) return doc;
  const obj = doc.toObject ? doc.toObject() : { ...doc };
  if (!obj.location) obj.location = { address: "", lat: null, lng: null };
  return obj;
}

/* ===================== SHOP ROUTES ===================== */

// Get all shops
app.get("/shops", async (req, res) => {
  try {
    const shops = await Shop.find();
    res.json({ success: true, message: "Shops fetched", shops: shops.map(sanitizeShopDoc) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get single shop with products
app.get("/shops/:shopId", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });
    res.json(sanitizeShopDoc(shop));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// NEW: Get products of a shop (convenience endpoint)
app.get("/shops/:shopId/products", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId).select("products");
    if (!shop) return res.status(404).json({ error: "Shop not found" });
    res.json({ success: true, products: shop.products || [] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Insert new shop (accepts nested location or flat fields)
app.post("/shops", async (req, res) => {
  try {
    const location = parseLocationFromBody(req.body);
    const payload = { ...req.body };
    if (location) payload.location = location;

    // Remove any extraneous top-level address/lat/lng if present to avoid duplicates
    delete payload.address;
    delete payload.lat;
    delete payload.lng;

    const shop = new Shop(payload);
    await shop.save();
    res.status(201).json(sanitizeShopDoc(shop));
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update shop (accepts nested location or flat fields)
app.put("/shops/:id", async (req, res) => {
  try {
    const location = parseLocationFromBody(req.body);
    const payload = { ...req.body };
    if (location) payload.location = location;

    delete payload.address;
    delete payload.lat;
    delete payload.lng;

    const updatedShop = await Shop.findByIdAndUpdate(req.params.id, payload, { new: true, runValidators: true });
    if (!updatedShop) return res.status(404).json({ error: "Shop not found" });
    res.json(sanitizeShopDoc(updatedShop));
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
    if (!shop) return res.status(404).json({ success: false, message: "Shop not found" });

    shop.products.push(req.body);
    await shop.save();
    res.status(201).json(sanitizeShopDoc(shop));
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
    res.json(sanitizeShopDoc(shop));
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete product
app.delete("/shops/:shopId/products/:productId", async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });

    const product = shop.products.id(req.params.productId);
    if (!product) return res.status(404).json({ error: "Product not found" });

    product.remove();
    await shop.save();
    res.json(sanitizeShopDoc(shop));
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});


/* ------------------- WORKER ROUTES ------------------- */

// Get all workers
app.get("/workers", async (req, res) => {
  try {
    const workers = await Worker.find().sort({ createdAt: -1 });
    res.json(workers);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
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

// Start server (listen on all interfaces so physical devices can reach it)
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));