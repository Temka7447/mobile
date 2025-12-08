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

// Update shop
app.put("/shops/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const updatedShop = await Shop.findByIdAndUpdate(id, req.body, { new: true });
    if (!updatedShop) return res.status(404).json({ error: "Shop not found" });
    res.json({ message: "Shop updated", updatedShop });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete shop
app.delete("/shops/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const deletedShop = await Shop.findByIdAndDelete(id);
    if (!deletedShop) return res.status(404).json({ error: "Shop not found" });
    res.json({ message: "Shop deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.listen(5000, () => console.log("Server running on port 5000"));
