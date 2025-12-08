const mongoose = require('mongoose');

const DeliveryItemSchema = new mongoose.Schema({
  productId: { type: String, required: true },
  name: { type: String },
  price: { type: Number },
  quantity: { type: Number, required: true, min: 0 },
}, { _id: false });

const DeliverySchema = new mongoose.Schema({
  pickupAddress: { type: String },
  deliverAddress: { type: String },
  receiverName: { type: String },
  receiverPhone: { type: String },
  weight: { type: String },
  fragile: { type: String },
  quantity: { type: Number },
  imageBase64: { type: String },

  // order metadata
  items: { type: [DeliveryItemSchema], default: [] },
  orderTotal: { type: Number, default: 0 },
  storeLocation: {
    address: { type: String, default: '' },
    lat: { type: Number },
    lng: { type: Number },
  },
}, { timestamps: true });

module.exports = mongoose.model('Delivery', DeliverySchema);