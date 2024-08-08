const admin = require('firebase-admin')
const serviceAccount = require('./talk-box-7bc47-firebase-adminsdk-2fd9p-7e43eddf8a.json')

    const adminInitApp = () => {
      let defaultApp
      
      if (!admin.apps.length) {
        defaultApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        })
      } else {
        defaultApp = admin.app()
      }

      return defaultApp
    }
    module.exports = {
        adminInitApp,
    }