
const jwt = require('jsonwebtoken');

module.exports = function (req,res,next) {
    //get the token from header if present
    const token = req.headers["x-auth-token"] || req.headers["authorization"];
    //if token not found return response without going to next middleware
    if(!token) return res.status(401).send("Access denied.No token provided");

    try{
        //if can verify token ,set req.user and pass to next middleware
        const decoded = jwt.verify(token,"myprivatekey");
        //config.get("myprivatekey")
        req.user = decoded;
        next();
    }
    catch{
        //if invalid token
        res.status(400).send("Invalid token.");
    }
}