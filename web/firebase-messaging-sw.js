// Firebase Messaging Service Worker for Web Push Notifications
// This file handles background push notifications on the web

importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
// These values will be replaced by flutterfire configure or should match your .env
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    image: payload.notification?.image,
    data: payload.data,
    actions: [
      { action: 'open', title: 'Open' },
      { action: 'close', title: 'Close' }
    ],
    requireInteraction: true,
    tag: payload.data?.type || 'default',
    renotify: true,
    vibrate: [200, 100, 200],
    timestamp: Date.now()
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification click received', event);

  event.notification.close();

  if (event.action === 'close') {
    return;
  }

  // Open the app or focus existing window
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // Check if there's already a window open
      for (const client of clientList) {
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          // Navigate to the appropriate route based on notification data
          const url = new URL(client.url);
          const data = event.notification.data;
          
          if (data?.orderId) {
            if (data.type?.startsWith('technician_')) {
              url.pathname = `/technician/accepted/${data.orderId}`;
            } else {
              url.pathname = `/orders/${data.orderId}/tracking`;
            }
            client.postMessage({ type: 'NAVIGATE', url: url.toString() });
          }
          return client.focus();
        }
      }

      // No window open, open a new one
      const url = new URL(self.location.origin);
      const data = event.notification.data;
      
      if (data?.orderId) {
        if (data.type?.startsWith('technician_')) {
          url.pathname = `/technician/accepted/${data.orderId}`;
        } else {
          url.pathname = `/orders/${data.orderId}/tracking`;
        }
      }
      
      return clients.openWindow(url.toString());
    })
  );
});

// Handle notification close
self.addEventListener('notificationclose', (event) => {
  console.log('[firebase-messaging-sw.js] Notification closed', event);
});

// Handle push subscription changes
self.addEventListener('pushsubscriptionchange', (event) => {
  console.log('[firebase-messaging-sw.js] Push subscription changed', event);
  
  event.waitUntil(
    // Re-subscribe to push
    messaging.getToken().then((token) => {
      if (token) {
        console.log('[firebase-messaging-sw.js] Token refreshed:', token);
        // Send token to your server
        return fetch('/api/update-fcm-token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ token })
        });
      }
    }).catch((err) => {
      console.error('[firebase-messaging-sw.js] Error refreshing token:', err);
    })
  );
});

// Skip waiting to activate immediately
self.addEventListener('install', (event) => {
  console.log('[firebase-messaging-sw.js] Service worker installed');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('[firebase-messaging-sw.js] Service worker activated');
  event.waitUntil(clients.claim());
});