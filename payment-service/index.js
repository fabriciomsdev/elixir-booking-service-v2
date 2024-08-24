const express = require('express');
const app = express();
const PORT = 3001;
app.use(express.json());


const state = {
    failures: 0,
    success: 0
}

const sleep = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms));
}

app.post('/api/payment-orders', async (req, res)=>{
    const payload = req.body;
    const result = {};
    let status = 200;
    console.log("Received payment order: ", payload);

    if(payload.amount > 1000){
        state.failures++;
        result.message = "Payment failed, amount is too high";
        status = 400;   
    } else {
        if (state.failures == state.success) {
            state.success++;
            result.message = "Payment successful";
            status = 200;
        } else {
            state.failures++;
            result.message = "Your bank reject the payment, please try again later.";
            status = 400;
        }
    }

    await sleep(2000);

    return res.status(status).send(result);
});

app.listen(PORT, (error) =>{
    if(!error)
        console.log("Server is Successfully Running, and App is  listening on port "+ PORT)
    else 
        console.log("Error occurred, server can't start", error);
    }
);