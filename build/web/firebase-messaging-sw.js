importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyBJNzwQHm7WnUWq0_3987hOJOuNY_xt7Lc",
    authDomain: "feelzeno.firebaseapp.com",
    projectId: "feelzeno",
    storageBucket: "feelzeno.appspot.com",
    messagingSenderId: "1093244166973",
    appId: "1:1093244166973:web:a24c5402407a688429db54"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});