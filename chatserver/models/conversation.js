const mongoose = require("mongoose");

//simple user schema
const ConversationSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      //required: true,
    },
    users: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
  },
  {
    timestamps: true,
  }
);

const Conversation = mongoose.model("Conversation", ConversationSchema);

module.exports = Conversation;
