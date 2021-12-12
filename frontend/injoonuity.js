// Javascript file for injoonuity.com

// API Gateway Endpoint
const url = "https://4akft8ggug.execute-api.us-east-1.amazonaws.com/default/visitorCountLambdaFunction";

// Fetch API request
fetch(url, {
    headers: {
        'x-api-key': 'cZPD4ldsID32FYvV8fgch3ouzC0eTYex9TdUWrgM'
    }
})
.then((response) => response.json())
.then(function(data) {
    let visitorCount = data;
    document.getElementById("visitorCount").innerHTML = visitorCount;
})
.catch(function(error) {
    console.log(error);
});
