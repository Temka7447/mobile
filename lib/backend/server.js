const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const Shop = require("./models/shop");

const app = express();
app.use(express.json());
app.use(cors());

mongoose.connect("mongodb://localhost:27017/Shop")
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));

// Get all shops
app.get("/shops", async (req, res) => {
  try {
    const shops = await Shop.find();
    res.json(shops);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get products of a specific shop
app.get("/shops/:shopId/products", async (req, res) => {
  try {
    const shopId = req.params.shopId;
    const shop = await Shop.findById(shopId);
    if (!shop) return res.status(404).json({ error: "Shop not found" });

    // Optionally, add shop info to each product
    const products = shop.products.map(product => ({
      ...product.toObject(),
      shopId: shop._id,
      shopName: shop.name
    }));

    res.json(products);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Insert new shop
app.post("/shops", async (req, res) => {
  try {
    const shop = new Shop(req.body);
    await shop.save();
    res.json({ message: "Shop saved", shop });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.listen(5000, () => console.log("Server running on port 5000"));
