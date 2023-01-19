import { Application, Request, Response } from "express";
import { Connection, FieldInfo, QueryOptions } from "mysql";

const express = require("express");
const cors = require("cors");
const dotenv = require('dotenv');
const mysql = require('mysql');

const app: Application = express();

app.use(express.json());
app.use(cors())

dotenv.config();

const DATABASE_HOSTNAME = process.env.DATABASE_HOSTNAME;
const DATABASE_USER = process.env.DATABASE_USER;
const DATABASE_PASSWORD = process.env.DATABASE_PASSWORD;
const API_PORT = process.env.API_PORT;


const sqlcon: Connection = mysql.createConnection({
    host: DATABASE_HOSTNAME,
    user: DATABASE_USER,
    password: DATABASE_PASSWORD,
    database: "chatapp",
    insecureAuth : true
});

sqlcon.connect(function(err) {
    if (err) throw err;
    console.log("Connected to MySQL host at: " + DATABASE_HOSTNAME);
});

app.listen(API_PORT, () => {
    console.log("Started API endpoint on port: " + API_PORT);
});

app.get("/chats", (req: Request, res: Response) => {
    const code = req.query.code;
    sqlcon.query("", (err: Error, result: any, fields: FieldInfo) => {
        if (err!=null) throw err;
        res.send(fields.);
    });
    
});