import mongoose from "mongoose";

// var db = "mongodb://localhost:27017/Main?authMechanism=DEFAULT&authSource=admin";
var db = "mongodb://localhost:27017";


const connectDb = () => {
  return mongoose
    .connect(db, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    })
    .then(() => {
      console.log("✅ MongoDB connected");
    })
    .catch((err) => {
      console.error("❌ MongoDB connection error:", err);
    });
};
export default connectDb;
