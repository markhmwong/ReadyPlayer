import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp()

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

// Notification - Host adds user to ready room

// Notification - User requests permission to join a ready room


// Invite to Room notification - method notifies the user with an invitation to a ready room receives an invitation
// export const inviteUser = functions.database.ref('/')

// Check all participants - immediately ends the check if all participants are ready

// Observe all participants - While progress check is live, observe the values from each participant
export const participantIncrement = functions.database.ref('/roomsCheck/{roomId}/userState/{userId}').onUpdate((change, context) => {
    const roomId = context.params.roomId;
    const after = change.after.val();
    //need to test
    if (after === true) {
        const numCheck = admin.database().ref('/roomsCheck/' + roomId + '/numCheck');
        return numCheck.transaction(count => {
            return count + 1;
        });
    }
    return null;
});

// Ready check did begin notification - A participant has begun the ready check
export const readyCheckBegan = functions.database.ref('/roomsCheck/{roomId}').onUpdate(async (change, context) => {
    const before = change.before.val();
    const after = change.after.val();
    const roomId = context.params.roomId;
    // const roomName = admin.database().ref('/rooms/' + roomId).child('name');
    var state: Boolean = true;

    // nothing changed
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

        try {
            // update and reset the state of the roomCheck
            return admin.messaging().sendToTopic(roomId, payload)
        }
        catch (error) {
            console.log("Error: ", error);
        }


    } else {
        // at this stage the ready check is complete
        // we will send a notification to all users subscribed to this room (topic)
        // but keep the state of the room as is, for users to view whether the check
        // was successful or unsuccessful. This includes who was ready and who was not ready.

        let dict = change.after.child('userState').val();
        
        for (const key in dict) {
            if (dict.hasOwnProperty(key)) {
                console.log(key, dict[key]);
                if (dict[key] === false) {
                    state = false;
                }
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

        try {
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
