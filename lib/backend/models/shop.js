const mongoose = require("mongoose");
const { v4: uuidv4 } = require('uuid');

/**
 * Notes:
 * - Replaced in-memory counters with UUID-based IDs to avoid duplicate IDs after server restarts.
 * - Added a nested `location` field (address, lat, lng).
 * - Product and Shop _id values are strings with a prefix to keep the old id shape (s_<uuid>, p_<uuid>).
 * - If you need sequential IDs across restarts, use a separate counter collection or a library like mongoose-sequence.
 */

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