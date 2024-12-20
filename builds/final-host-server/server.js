const express = require("express");

const PORT = 8000
const app = express()

app.use(express.static("public"));

app.use(express.json());

app.get("/", (req, res) => {
    res.sendFile("public/index.html");
});

app.put("/api/put_round", (req, res) => {
    console.log("Request Confirmed!");
    console.log(req.body);
    res.sendStatus(300);
});

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}.`);
});