const functions = require('firebase-functions')
const admin = require('firebase-admin')

admin.initializeApp();
const {
    RtcTokenBuilder,
    RtcRole,
    RtmTokenBuilder,
} = require('agora-access-token')
const adminInitApp = require('../adminInitApp.js')

const defaultApp = adminInitApp() 

const db = admin.firestore() 

const createCallsWithTokens = functions.https.onCall(async (data,context) =>  {
    try {
        const appId = '92b218ac6c974235b2ec39b2f57079b4'
        const appCertificate = 'e37d31d6beeb4d35908ac1bc1daf24ab'
        const role = RtcRole.PUBLISHER
        const expirationTimeInSeconds = 3600
        const currentTimestamp = Math.floor(Date.now() / 1000)
        const privilageExpired = currentTimestamp + expirationTimeInSeconds
        const uid = 0
        const channelName = Math.floor(Math.random() * 100).toString()
        const token = RtcTokenBuilder.buildTokenWithUid(
            appId,
            appCertificate,
            channelName,
            uid,
            role,
            privilageExpired
        )
        return {
            data : {
                token: token,
                channelId: channelName, 
            }
        }
    } catch (error){
        console.log(error)
    }
})

module.exports = {
    createCallsWithTokens,
}