"use strict";
//Notice that this is not really good code, dont take an example of this one...
Object.defineProperty(exports, "__esModule", { value: true });
const express = require("express");
const cors = require("cors");
const dotenv = require('dotenv');
const mysql = require("mysql2");
const app = express();
app.use(express.json());
app.use(cors());
dotenv.config();
const DATABASE_HOSTNAME = process.env.DATABASE_HOSTNAME;
const DATABASE_USER = process.env.DATABASE_USER;
const DATABASE_PASSWORD = process.env.DATABASE_PASSWORD;
const API_PORT = process.env.API_PORT;
const connection = mysql.createConnection({
    host: DATABASE_HOSTNAME,
    user: DATABASE_USER,
    password: DATABASE_PASSWORD,
    database: "chatapp",
    namedPlaceholders: true
});
connection.connect(function (err) {
    if (err)
        throw err;
    console.log("Connected to MySQL host at: " + DATABASE_HOSTNAME);
});
app.listen(API_PORT, () => {
    console.log("Started API endpoint on port: " + API_PORT);
});
app.get("/messages", (req, res) => {
    const code = req.query.code;
    const count = req.query.count;
    connection.execute("SELECT * FROM message JOIN sessions ON message.fk_sessions_id=sessions.p_sessions_id WHERE sessions.joincode=:code ORDER BY message.creationtime ASC LIMIT :count", { code: code, count: count }, (err, rows) => {
        try {
            if (err) {
                res.json({
                    Success: false,
                    payload: "Cannot fetch data",
                    Error: err
                });
                return;
            }
            res.json({
                Success: true,
                payload: rows,
                Error: null
            });
        }
        catch (err) {
            res.json({
                Success: false,
                payload: "Failed to process query",
                Error: err
            });
        }
    });
});
app.post("/createsession", async (req, res) => {
    const code = req.query.code;
    try {
        //You officially entered the Callback Hell (never do this, I was jung and dumb...) instead use await
        connection.execute("SELECT * FROM sessions WHERE joincode=?", [code], (err, rows) => {
            if (err)
                console.error(err);
            if (rows[0] != undefined) {
                res.json({
                    Success: false,
                    Error: "Session already exists"
                });
                return;
            }
            connection.execute("INSERT INTO sessions (joincode) Values (?)", [code], (err, rows) => {
                if (err)
                    throw err;
                res.json({
                    Success: true,
                    Error: null
                });
                return;
            });
        });
    }
    catch (err) {
        res.json({
            Success: false,
            Error: err
        });
    }
});
app.post("/message", (req, res) => {
    const code = req.query.code;
    const message = req.body.message;
    try {
        //Enter the Callbackhell again
        connection.execute("SELECT p_sessions_id FROM sessions WHERE joincode=? LIMIT 1", [code], (err, rows) => {
            if (err)
                console.error(err);
            connection.execute("INSERT INTO message (message, fk_sessions_id) VALUES (:message, :fk_sessions_id)", { message: message, fk_sessions_id: rows[0].p_sessions_id }, (err, rows) => {
                if (err)
                    throw err;
                res.json({
                    Success: true,
                    Error: null
                });
            });
        });
    }
    catch (err) {
        res.json({
            Success: false,
            Error: err
        });
    }
});
//# sourceMappingURL=main.js.map