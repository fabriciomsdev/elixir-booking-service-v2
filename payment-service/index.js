const express = require('express');
const app = express();
const PORT = 3001;

const state = {
    failures: 0,
    success: 0
}

app.post('/payment-order', (req, res)=>{
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

    return res.status(status).send(result);
});

app.listen(PORT, (error) =>{
    if(!error)
        console.log("Server is Successfully Running, and App is  listening on port "+ PORT)
    else 
        console.log("Error occurred, server can't start", error);
    }
);