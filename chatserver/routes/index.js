var express = require('express');
const Conversation = require('../models/conversation');
var router = express.Router();
const Message = require('../models/message');
const auth = require('../middleware/auth');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/message',async(req,res)=>{
  let messages =await Message.find({});
  //console.log(messages);
  res.send(messages);
});

router.delete('/message',async(req,res)=>{
  await Message.remove({});
  res.send(true);
});


router.get('/conversation',async(req,res)=>{
  let conversation =await Conversation.find({}).populate('users');
  //console.log(conversation);
  res.send(conversation);
});
router.post('/conversation',auth,async(req,res)=>{
  let currentUser = req.user._id;
  let anotherUser = req.body.userid;
  //console.log(currentUser);
  let conversation = new Conversation({
    name: req.body.name,
    users:[currentUser,anotherUser]
  })
  conversation.save();
  res.send(conversation);
});

module.exports = router;
