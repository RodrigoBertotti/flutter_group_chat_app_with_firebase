importScripts('https://www.gstatic.com/firebasejs/10.5.2/firebase-app-compat.js')
importScripts('https://www.gstatic.com/firebasejs/10.5.2/firebase-messaging-compat.js')

// my custom environment file for firebase
importScripts('environment.js')

if (!environment.firebase?.apiKey?.length) {
   console.error("Missing environment values for web, push notifications won't work")
   console.error("1. Copy the values from copy the values from the \"web\" field in the \"flutter_app/lib/firebase_options.dart\" file ")
   console.error("2. Paste the values in the `flutter_app/web/environment.js` file")
} else {
   const app = firebase.initializeApp(environment.firebase);
   firebase.messaging().onBackgroundMessage((payload) => {
      console.log("onBackgroundMessage");
      console.log(payload);
      return self.registration.showNotification(payload.notification.title, {body: payload.notification.body});
   })
}
