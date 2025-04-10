// firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging.js');


firebase.initializeApp({
    apiKey: 'AIzaSyCGbZpjekvZuGIrhQbhDJxFTRxpIj7klz4',
    appId: '1:194268838181:web:d0b0535177fe5aa9fd82cc',
    messagingSenderId: '194268838181',
    projectId: 'inclass-b0757',
    authDomain: 'inclass-b0757.firebaseapp.com',
    storageBucket: 'inclass-b0757.firebasestorage.app',
});

// Retrieve firebase messaging
const messaging = firebase.messaging();
