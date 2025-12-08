const mongoose = require("mongoose");

const workerSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    phone: { type: String, default: "", trim: true },
    vehicle: { type: String, default: "", trim: true },
    email: { type: String, default: "", trim: true },
    imageUrl: { type: String, default: "" } // Google URL or custom
  },
  { timestamps: true }
);

module.exports = mongoose.model("Worker", workerSchema);
