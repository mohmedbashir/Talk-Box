const functions = require("firebase-functions");
const {
    createCallsWithTokens,
} = require('./createCallsWithTokens/createCallsWithTokens.js')
const { adminInitApp } = require('./adminInitApp')
admin.initializeApp();

adminInitApp()

module.exports = {
    createCallsWithTokens,
}