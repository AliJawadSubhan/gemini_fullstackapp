
const { GoogleGenerativeAI } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI("AIzaSyBnSzk7AqBimFObeA1BaC8SKgLzCSLGGhg");
const model = genAI.getGenerativeModel({ model: "gemini-pro-vision" });

const modelWithoutImage = genAI.getGenerativeModel({ model: "gemini-1.0-pro" });

const express = require('express');
const multer = require("multer");
const app = express();
const fs = require("fs");
const { log } = require("console");

const upload = multer({
    storage: multer.diskStorage({
        destination: function (req, file, cb) {
            cb(null, 'uploads')
        },
        filename: function (req, file, cb) {
            cb(null, file.fieldname + "-" + ".png")
        }
    })
}).single('client_image');

async function sendGeminiAIData(input) {
    const result = await modelWithoutImage.generateContent(input);
    const response = await result.response;
    const text = response.text();
    console.log(text);
    return text;
}

function fileToGenerativePart(path, mimeType) {
    return {
        inlineData: {
            data: Buffer.from(fs.readFileSync(path)).toString("base64"),
            mimeType
        },
    };
}

async function run(imagePath, prompty) {
    const model = genAI.getGenerativeModel({ model: "gemini-pro-vision" });

    const imageParts = fileToGenerativePart(imagePath, "image/png");



    const result = await model.generateContent([prompty, imageParts]);
    const response = await result.response;
    const text = response.text();
    console.log(text);
    return text;
}



app.use(express.json());



app.get("/", async (request, response) => {
    return response.status(200).json(successHandler("Hey, this is a test API"));
})
app.post('/chatWithGemini', upload, async (request, response) => {
    try {
        let message = request.body.message;
        console.log(message);
        console.log(message + " This is the message from the client.");
        const clientName = "Ali Jawad";
        const prompt = `${message}  {This is a different message from the backend,  The Client name is ${clientName}, your output language should always be English no matter what}. `;

        const responseFromAI = await run('uploads/client_image-' + '.png', prompt);
        return response.status(200).json(successHandler("AI responded successfully.", {
            "message": responseFromAI,
            "isAi": true,
        }));
    } catch (error) {
        console.log(error);
        return response.status(404).json(errorHandler(`${error}.`));

    }
});


app.get('/*', async (request, response) => {
    return response.status(404).json(errorHandler("Unkown Route."));
});

app.post('/chatWithGeminiWithoutChat', async (request, response) => {
    try {
        let message = request.body.message;
        console.log(message + " This is the message from the client.");
        const clientName = "Ali Jawad";

        // Construct the prompt to include the context and refer to the client by name implicitly
        const prompt = `${message}   {This is a different message from the backend,  The Client name is ${clientName}, your output language should always be English no matter what}. `;

        const responseFromAI = await sendGeminiAIData(prompt);

        return response.status(200).json(successHandler("AI responded successfully.", {
            "message": responseFromAI,
            "isAi": true,
        }));
    } catch (error) {
        return response.status(404).json(errorHandler(`${error}.`));

    }
});


app.listen(6000, () => {
    console.log("It is running on Port 6000");
});
// fetch("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=AIzaSyBnSzk7AqBimFObeA1BaC8SKgLzCSLGGhg", {
//     method: "POST",
//     body: JSON.stringify({
//         "contents": [{ "parts": [{ "text": "What is above you?" }] }]
//     }),

// })
// .then((response) => response.json())
// .then((json) => {
//     // const content = json['candidates'][0]["content"]['parts'];
//     console.log(json);
// },);

function successHandler(message, data) {
    return {
        "success": true,
        "message": message,
        "data": data
    };
}

function errorHandler(message) {
    return {
        "success": false,
        "message": message,

    };
}
