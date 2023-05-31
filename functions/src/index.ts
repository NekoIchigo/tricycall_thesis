import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as geolib from "geolib";

admin.initializeApp();

exports.checkHelth = functions.https.onCall(async (data, context) => {
  return "The function is online";
});

export const bookRide = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snapshot, context) => {
    const bookingId = context.params.bookingId;

    // Function to process the booking when a driver becomes available
    const processBooking = async () => {
      // Get all online drivers ordered by their availability timestamp
      const onlineDriversSnapshot = await admin
        .firestore()
        .collection("driver_status")
        .where("status", "==", "online")
        .orderBy("availability_timestamp")
        .get();
      console.log("Success getting drivers list");
      // Assign the booking to the next available driver in the queue
      let assignedDriverId: string | null = null;
      onlineDriversSnapshot.forEach((driverSnapshot) => {
        if (!assignedDriverId) {
          assignedDriverId = driverSnapshot.id;
          console.log("Driver data" + driverSnapshot.id);
          // Update the driver's status to "booked"
          driverSnapshot.ref.update({status: "booked"});
        }
      });

      if (assignedDriverId) {
        // Update the booking with the assigned driver
        await snapshot.ref.update({driver_id: assignedDriverId});

        // Send notification to the assigned driver
        const driverToken = await getDriverToken(assignedDriverId);
        const notificationPayload = {
          token: driverToken,
          notification: {
            title: "New Booking",
            body: "You have a new booking request",
          },
          data: {
            bookingData: bookingId,
            user: "driver",
          },
        };

        await sendNotificationToDevice(notificationPayload);
      } else {
        // No available drivers found, listen for driver status changes
        const unsubscribe = admin
          .firestore()
          .collection("driver_status")
          .where("status", "==", "online")
          .orderBy("availability_timestamp")
          .limit(1)
          .onSnapshot(async (snapshot) => {
            if (!snapshot.empty) {
              unsubscribe(); // Stop listening to further changes
              await processBooking(); // Process the booking again
            }
          });
      }
    };

    await processBooking(); // Start processing the booking

    // Other code (if any) related to the onCreate function
  });

/**
 * Retrieves the driver's token from the Firestore database.
 * @param {string} driverId - The ID of the driver.
 * @return {Promise<string>} The driver's token.
 */
async function getDriverToken(driverId: string): Promise<string> {
  const driverSnapshot = await admin.firestore()
    .collection("driver_status")
    .doc(driverId).get();
  const driverData = driverSnapshot.data();

  if (driverData && driverData.token) {
    return driverData.token;
  } else {
    throw new Error("Driver data not found or invalid");
  }
}

/**
 * Sends a notification to a specific device using its registration token.
 *
 * @param {admin.messaging.Message} notificationPayload
 * - The payload containing the notification data.
 * @return {Promise<void>}
 * A Promise that resolves when the notification is successfully sent.
 * @throws {Error} If there is an error sending the notification.
 */
async function sendNotificationToDevice(
  notificationPayload: admin.messaging.Message
): Promise<void> {
  try {
    const response = await admin.messaging().send(notificationPayload);
    console.log("Notification sent successfully:", response);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

exports.driverResponse = functions.https.onCall(async (data, context) => {
  const {driverId, bookingId, response} = data;
  console
    .log("Request :" + ", " + driverId + ", " + bookingId + ", " + response);
  try {
    const bookingDataSnapshot = await admin.firestore()
      .collection("bookings")
      .doc(bookingId)
      .get();
    console
      .log("Booking User ID :" + ", " + bookingDataSnapshot.data()?.user_id);
    if (response === "declined") {
      const pickupLocation = bookingDataSnapshot.data()?.pick_up_location;

      // Get all online drivers except the one who declined
      const onlineDriversSnapshot = await admin
        .firestore()
        .collection("driver_status")
        .where("status", "==", "online")
        .where(admin.firestore.FieldPath.documentId(), "!=", driverId)
        .get();

      // Calculate the distance between pickup location and each online driver
      let nearestDriverId: string | null = null;
      let nearestDriverDistance: number | null = null;

      onlineDriversSnapshot.forEach((driverSnapshot) => {
        const driverData = driverSnapshot.data();
        const driverLocation = {
          latitude: driverData.latitude,
          longitude: driverData.longitude,
        };
        const distance: number = geolib.
          getDistance(pickupLocation, driverLocation);

        if (nearestDriverDistance === null ||
          distance < nearestDriverDistance) {
          nearestDriverId = driverSnapshot.id;
          nearestDriverDistance = distance;
        }
      });

      console.log("Driver ID:" + nearestDriverId);
      if (nearestDriverId) {
        // Send booking offer to the new driver
        const driverToken = await getDriverToken(nearestDriverId);
        const notificationPayload = {
          token: driverToken,
          notification: {
            title: "New Booking",
            body: "You have a new booking request",
          },
          data: {
            bookingData: bookingId,
            user: "driver",
          },
        };
        await sendNotificationToDevice(notificationPayload);
      }

      // Update the status of the driver who declined to "online"
      await admin.firestore()
        .collection("driver_status")
        .doc(driverId)
        .update({status: "online"});

      return "success";
    } else {
      return "success";
    }
  } catch (error) {
    console.error("Error:", error);
    throw new functions.https.
      HttpsError("internal", "Error sending driver response");
  }
});
