const mongoose = require("mongoose");
const { v4: uuidv4 } = require('uuid');

/* Product Schema */
const productSchema = new mongoose.Schema({
  _id: { type: String, default: () => `p_${uuidv4()}` }, // auto string ID
  name: { type: String, required: true },
  price: { type: Number, default: 0 },
  imagePath: { type: String, default: "" },
  quantity: { type: Number, default: 0 }
}, { _id: false });

/* Location sub-schema */
const locationSchema = new mongoose.Schema({
  address: { type: String, default: "" },
  lat: { type: Number, default: null },
  lng: { type: Number, default: null }
}, { _id: false });

/* Shop Schema */
const shopSchema = new mongoose.Schema(
  {
    _id: { type: String, default: () => `s_${uuidv4()}` }, // auto string ID
    name: { type: String, required: true },
    phone: { type: String, default: "" },
    imagePath: { type: String, default: "" },
    products: { type: [productSchema], default: [] },
    location: { type: locationSchema, default: () => ({}) }
  },
  {
    timestamps: true,
    collection: "Shop"
  }
);

module.exports = mongoose.model("Shop", shopSchema);