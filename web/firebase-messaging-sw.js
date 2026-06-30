importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBWL8amPfcGmXU0iHQUT3VCmwW9BxYd5L0',
  appId: '1:219118146107:web:f0f9ffe80dc0a575a2421e',
  messagingSenderId: '219118146107',
  projectId: 'sri-gowri-ganesha',
  authDomain: 'sri-gowri-ganesha.firebaseapp.com',
  storageBucket: 'sri-gowri-ganesha.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const data = payload.data || {};
  const notificationTitle = payload.notification?.title || 'Sankalpa';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: data,
    vibrate: [200, 100, 200],
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification.data || {};
  const entityType = data.entityType || '';
  const entityId = data.entityId || '';

  const routeMap = {
    'expense': '/expenses/' + entityId + '/edit',
    'target': '/collections/' + entityId,
    'followup': '/followups/' + entityId + '/edit',
    'daily_collection': '/daily-collections',
    'settings': '/settings',
  };

  const url = new URL(routeMap[entityType] || '/', self.location.origin);

  const focusAndNavigate = async () => {
    const clients = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of clients) {
      if (client.url.startsWith(self.location.origin) && 'navigate' in client) {
        await client.navigate(url.toString());
        return client.focus();
      }
    }
    return self.clients.openWindow(url.toString());
  };

  event.waitUntil(focusAndNavigate());
});
