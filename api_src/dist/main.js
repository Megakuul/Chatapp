"use strict";
exports.__esModule = true;
var express = require("express");
var cors = require("cors");
var dotenv = require('dotenv');
var mysql = require('mysql');
var app = express();
app.use(express.json());
app.use(cors());
dotenv.config();
var DATABASE_HOSTNAME = process.env.DATABASE_HOSTNAME;
var DATABASE_USER = process.env.DATABASE_USER;
var DATABASE_PASSWORD = process.env.DATABASE_PASSWORD;
var API_PORT = process.env.API_PORT;
var sqlcon = mysql.createConnection({
    host: DATABASE_HOSTNAME,
    user: DATABASE_USER,
    password: DATABASE_PASSWORD,
    database: "chatapp",
    insecureAuth: true
});
sqlcon.connect(function (err) {
    if (err)
        throw err;
    console.log("Connected to MySQL host at: " + DATABASE_HOSTNAME);
});
app.listen(API_PORT, function () {
    console.log("Started API endpoint on port: " + API_PORT);
});
app.get("/chats", function (req, res) {
    var code = req.query.code;
    sqlcon.query("", function (err, result, fields) {
        if (err != null)
            throw err;
        res.send(fields.);
    });
});
//# sourceMappingURL=main.js.map