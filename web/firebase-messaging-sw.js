// firebase-messaging-sw.js
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: 'AIzaSyAKWT7cM_O-d9RCtwP5xS_yZd4XBtqfrqA',
  authDomain: 'orre-be.firebaseapp.com',
  measurementId: 'G-B75ET8W50Y',
  projectId: 'orre-be',
  storageBucket: 'orre-be.appspot.com',
  messagingSenderId: '171129567626',
  appId: '1:171129567626:web:7ca382d37414c50e2db073',
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});