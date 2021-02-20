var express = require('express');
var router = express.Router();
const {User,validate} = require('../models/user');
const bcrypt = require("bcrypt"); 
const Joi = require('@hapi/joi');


/* GET users listing. */
router.get('/',async function(req, res, next) {
  let users = await User.find({});
  res.send(users);
  //res.send('respond with a resource');
});


//register user
router.post("/",async (req,res,next)=>{
  

  //validate the request body first
  const {error} = validate(req.body);
  //console.log(error.details[0].message);
  if(error) return res.status(400).send({message:error.details[0].message});
  

  // finding existing user
  let user = await User.findOne({email:req.body.email});
  if(user) return res.status(400).send({message:'User already registered'});
  
  //create user object 
  user = new User({
      username: req.body.username,
      email: req.body.email,
      password: req.body.password,
    });
    //hashing user password using bcrypt
     user.password = await bcrypt.hash(user.password,10);
     //console.log(user);
  try{
    //saving user object in data base
     let {_id}= await user.save();
    //console.log(_id);
     //generate authentication token
    const token = user.generateAuthToken();

    res.header({
      "x-auth-token":token,
        "user_id":_id}).sendStatus(200);
    //console.log(token);
    
  }catch(error){
    res.status(400).json({ 
      error: error.toString() 
    });
  }
 });
 //delete all users
 router.delete('/',async (req,res,next)=>{
   await User.remove({});
   res.send(true);
 })

 //login user
router.post('/login', async (req,res,next)=>{
  //validate the request body first
  const {error} = validateUser(req.body);
  //console.log(validateUser(req.body));
  if(error) return res.status(400).send(error.details[0].message);

  //finding the user
  let user = await User.findOne({email:req.body.email});
  //console.log(user);
  if(!user) return res.status(400).send("Invalid email or password");

  //comparing password using bcrypt
   var validPassword = await bcrypt.compare(req.body.password,user.password)

   if(!validPassword) return res.status(400).send("Invalid email or password");

   const token = user.generateAuthToken();
   res.header({
    "x-auth-token":token,
      "user_id":user._id}).sendStatus(200);

});

//function to validate user
function validateUser(req){
  const schema =Joi.object({
      email:Joi.string().min(3).max(255).required(),
      password:Joi.string().min(8).max(255).required(),
  })
  return schema.validate(req);;
}
module.exports = router;
