
const { GoogleGenerativeAI } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI("AIzaSyBnSzk7AqBimFObeA1BaC8SKgLzCSLGGhg");
const model = genAI.getGenerativeModel({ model: "gemini-1.0-pro" });
const express = require('express');
const app = express();



async function sendGeminiAIData(input) {
    const result = await model.generateContent(input);
    const response = await result.response;
    const text = response.text();
    console.log(text);
    return text;

}


app.use(express.json());



app.get("/", async (request, response) => {
    return response.status(200).json(successHandler("Hey, this is a test API"));
})
app.post('/chatWithGemini', async (request, response) => {
    try {
        let message = request.body.message;
        console.log(message + " This is the message from the client.");
        const clientName = "Ali Jawad";


        // Construct the prompt to include the context and refer to the client by name implicitly
        const prompt = `${message}  [As a follow-up, Please address the client directly as ${clientName}]. `;

        const responseFromAI = await sendGeminiAIData(prompt);

        return response.status(200).json(successHandler("AI responded successfully.", {
            "message": responseFromAI,
            "isAi": true,
        }));
    } catch (error) {
        return response.status(404).json(errorHandler(`${error}.`));

    }
});
console.log("test");

app.get('/*', async (request, response) => {
    return response.status(404).json(errorHandler("Unkown Route."));
});


app.listen(6000, () => {
    console.log("It is running on Port 6000");
});
// fetch("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBnSzk7AqBimFObeA1BaC8SKgLzCSLGGhg", {
//     method: "POST",
//     body: JSON.stringify({
//         "contents": [{ "parts": [{ "text": "What is above you?" }] }]
//     }),

// })
//     .then((response) => response.json())
//     .then((json) => {
//         const content = json['candidates'][0]["content"]['parts'];
//         console.log(content);
//     },);

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
