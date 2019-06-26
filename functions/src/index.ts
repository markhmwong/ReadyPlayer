import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp()

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

// Host adds user to ready room

// User requests permission to join a ready room


// Invite to Room notification - method notifies the user with an invitation to a ready room receives an invitation
// export const inviteUser = functions.database.ref('/')

// Check all participants

// Observe all participants - While progress check is live, observe the values from each participant


// Ready check did begin notification - A participant has begun the ready check
export const readyCheckBegan = functions.database.ref('/roomsCheck/{roomId}').onUpdate(async (change, context) => {
    const before = change.before.val();
    
    const after = change.after.val();
    const roomId = context.params.roomId;

    if (before.inProgress === after.inProgress) {
        return null;
    }

    if (after.inProgress === true) {
        const payload = {
            notification: {
                title: "Ready Check Started",
                body: ""
            }
        };

        return admin.messaging().sendToTopic(roomId, payload)
        .then(function(response) {
            console.log("Success:", response);
        })
        .catch(function(error) {
            console.log("Error: ", error);
        });
    } else {
        //on end send notification, ready check complete
        console.log("ready check ended");

        // console.log(change.after.child('userState').val());
        let dict = change.after.child('userState').val();
        let state: Boolean = true;
        // var userStateDict: { [key: string]: any[] } = {};
        for (const key in dict) {
            if (dict.hasOwnProperty(key)) {
                console.log(key, dict[key]);
                if (dict[key] === false) {
                    state = false;
                }
                // let value = dict[key];
                // userStateDict[key] = value;
            }
        }
        let completedPayload = { };
        if (state) {
            //successful ready check
            completedPayload = {
                notification: {
                    title: "Success",
                    body: ""
                }
            }; 

        } else {
            //unsuccessful
            completedPayload = {
                notification: {
                    title: "Unsuccessful",
                    body: ""
                }
            };
        }

        //reset userState
        for (const key in dict) {
            if (dict.hasOwnProperty(key)) {
                dict[key] = false
            }
        }

        try {
            await change.after.ref.update({ userState: dict });
            return admin.messaging().sendToTopic(roomId, completedPayload)
        }
        catch (error) {
            console.log("Error: ", error);
        }
    }

    return null;
});

// Ready check did end notification - All participants in room have completed their ready check


// Test notification
export const testNotification = functions.database.ref('/rooms/{roomId}').onCreate((snapshot, context) => {
    const roomId = context.params.roomId
    const roomName = snapshot.child('name').val();

    const payload = {
        notification: {
            title: roomName,
            body: roomId
        }
    };

    return admin.messaging().sendToTopic("chatRoom", payload)
    .then(function(response) {
        console.log("Success:", response);
    })
    .catch(function(error) {
        console.log("Error: ", error);
    });
});

// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
