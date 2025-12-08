const mongoose = require("mongoose");

// Helper function to generate next shop/product ID
let shopCounter = 1;
let productCounter = 1;

function generateShopId() {
  return `s_${shopCounter++}`;
}

function generateProductId() {
  return `p_${productCounter++}`;
}

// Product Schema
const productSchema = new mongoose.Schema({
  _id: { type: String, default: generateProductId }, // auto string ID
  name: { type: String, required: true },
  price: { type: Number, default: 0 },
  imagePath: { type: String, default: "" },
  quantity: { type: Number, default: 0 }
});

// Shop Schema
const shopSchema = new mongoose.Schema(
  {
    _id: { type: String, default: generateShopId }, // auto string ID
    name: { type: String, required: true },
    phone: { type: String, default: "" },
    imagePath: { type: String, default: "" },
    products: { type: [productSchema], default: [] }
  },
  {
    timestamps: true,
    collection: "Shop"
  }
);

module.exports = mongoose.model("Shop", shopSchema);
