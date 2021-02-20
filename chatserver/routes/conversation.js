var express = require('express');
const Conversation = require('../models/conversation');
var router = express.Router();
const auth = require('../middleware/auth');


router.get('/',auth,async(req,res)=>{
    let userId = req.user._id;
  let conversation =await Conversation.find({users:userId}).populate('users');
  //console.log(conversation);
  res.send(conversation);
});
router.post('/',auth,async(req,res)=>{
  let currentUser = req.user._id;
  let anotherUser = req.body.userid;
  let name ="conversatoin";
  //console.log(currentUser);
  let conversation = new Conversation({
    name: name,
    users:[currentUser,anotherUser]
  })
  conversation.save();
  res.send(conversation);
});

router.delete('/',async(req,res)=>{
    await Conversation.remove();
    res.send(200);
})

module.exports = router;
