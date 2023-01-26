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

app.get("/messages", (req: Request, res: Response) => {
    const code = req.query.code;
    const count = req.query.count;

    const query = "SELECT * FROM message where s"

    sqlcon.query(query, (err: Error, result: any, fields: FieldInfo) => {
        if (err!=null) throw err;
        res.send(fields);
    });
});

app.post("/session", (req: Request, res: Response) => {
    const code = req.query.code;

    const query = `
        PREPARE createSession FROM 'INSERT INTO sessions (joincode) Values (?)';
        SET @code = '${code}';
        EXECUTE createSession USING @code;
    `;

    sqlcon.query(query, (err: Error, result: any, fields: FieldInfo) => {
        if (err==null||err==undefined) {
            res.json({
                Success: false,
                Error: err
            });
            return;
        }
        res.json({
            Success: true,
            Error: null
        })
    });
});

app.post("/message", (req: Request, res: Response) => {
    const code = req.query.code;

    const query = "INSERT INTO message (name, address) VALUES ('Company Inc', 'Highway 37')";

    sqlcon.query(query, (err: Error, result: any, fields: FieldInfo) => {

    });
});