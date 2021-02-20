const mongoose = require("mongoose");

//simple message schema
const MessageSchema = new mongoose.Schema(
  {
    message: {
      type: String,
      required: true,
    },
    conversation: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
    },
    sender:{
      type:mongoose.Schema.Types.ObjectId,
      ref:'User'
    },
    reciver:{
      type:mongoose.Schema.Types.ObjectId,
      ref:'User'
    }
    
  },
  {
    timestamps: true,
  }
);

const Message = mongoose.model("Message", MessageSchema);

module.exports = Message;
