var createError = require("http-errors");
var express = require("express");
var path = require("path");
var cookieParser = require("cookie-parser");
var logger = require("morgan");
var socket_io = require("socket.io");
const mongoose = require("mongoose");
const jwt = require("jsonwebtoken");

const cors = require("cors");

const Message = require("./models/message");

var indexRouter = require("./routes/index");
var usersRouter = require("./routes/users");
const Conversation = require("./models/conversation");
var conversationRouter = require("./routes/conversation");


var app = express();
//connect to mongodb
mongoose
  .connect("mongodb://localhost/chatAppTest", { useNewUrlParser: true })
  .then(() => console.log("Connected to MongoDB..."))
  .catch((err) => console.error("Could not connect to MongoDB..."));

// Socket.io
var io = socket_io();
app.io = io;

// view engine setup
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "jade");

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use(cors());

app.use("/", indexRouter);
app.use("/users", usersRouter);
app.use('/conversation',conversationRouter);

var sockets = [];

io.on("connection", async (socket) => {
  console.log("a user connected");
  socket.on('connect', function () {
  })
  //reciving create conversation
  socket.on("userId", (userId) => {
    let user = {
      userId: userId,
      socketId: socket.id,
    };
    sockets.push(user);
  });

  socket.on("conversation", async (conv) => {
    console.log(conv);
    let message = await Message.find({ conversation: conv });
    console.log(message);
    let conversation = await Conversation.findById(conv);
    conversation.users.forEach((id) => {
      //console.log(id)
      sockets
        .filter((e) => e.userId == id)
        .forEach((socket) => {
          //console.log(socket);
          //socket.join(socket.socketId);
          io.to(socket.socketId).emit("chat message", 'message');
        });
    });
  });
  socket.on("send message", async (msg) => {
    //console.log("user sent a message");
    console.log(msg);
    let message = new Message({
      message: msg.message,
      conversation: msg.conversation,
      sender: msg.sender,
      reciver: msg.reciver,
    });
     let newMessage = await message.save();
    // const result = sockets.find(({ userId }) => userId === msg.reciver);
    // const sender = sockets.find(({ userId }) => userId === msg.sender);

    // //io.emit("new message", newMessage);
    // //io.emit("new message", newMessage);
    // io.to(sender.socketId).to(result.socketId).emit("new message", newMessage);
  });

  socket.on("error", function (err) {
    console.log("Socket.IO Error");
    console.log(err.stack); // this is changed from your code in last comment
  });
});

// catch 404 and forward to error handler
app.use(function (req, res, next) {
  next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get("env") === "development" ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render("error");
});

module.exports = app;
