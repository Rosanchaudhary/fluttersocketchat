const Joi = require('@hapi/joi');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');



//simple user schema
const UserSchema = new mongoose.Schema({
    username:{
        type:String,
        required:true,
        minlength:3,
        maxlength:50
    },
    email:{
        type:String,
        required:true,
        minlength:5,
        maxlength:255,
        unique:true
    },
    password:{
        type:String,
        required:true,
        minlength:8,
        maxlength:255
    },
},
{
    timestamps:true
}
);

//custom method to generate web token
UserSchema.methods.generateAuthToken = function(){
    const token = jwt.sign({_id:this._id,isAdmin:this.isAdmin},'myprivatekey');
    return token;    
}

const User = mongoose.model('User',UserSchema);


//function to validate user
function validateUser(user){
    const schema =Joi.object({
        username:Joi.string().min(3).max(50).required(),
        email:Joi.string().min(3).max(255).required(),
        password:Joi.string().min(8).max(255).required(),
    })
    return schema.validate(user);;
}

exports.User = User; 
exports.validate = validateUser;