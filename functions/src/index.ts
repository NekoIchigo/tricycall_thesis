import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as geolib from "geolib";

admin.initializeApp();

exports.checkHelth = functions.https.onCall(async (data, context) => {
  return "The function is online";
});

export const bookRide = functions.firestore.document("bookings/{bookingId}")
  .onCreate(async (snapshot, context) => {
    const bookingData = snapshot.data();
    const bookingId = context.params.bookingId;
    const pickupLocation = bookingData.pick_up_location;

    // Get all online drivers
    const onlineDriversSnapshot = await admin.firestore()
      .collection("driver_status").where("status", "==", "online").get();

    // Calculate the distance between pickup location and each online driver
    let nearestDriverId: string | null = null;
    let nearestDriverDistance: number | null = null;

    onlineDriversSnapshot.forEach((driverSnapshot) => {
      const driverData = driverSnapshot.data();
      const driverLocation = {
        latitude: driverData.latitude,
        longitude: driverData.longitude,
      };
      const distance = geolib.getDistance(pickupLocation, driverLocation);

      if (nearestDriverDistance === null || distance < nearestDriverDistance) {
        nearestDriverId = driverSnapshot.id;
        nearestDriverDistance = distance;
      }
    });

    // Assign the nearest driver to the booking
    if (nearestDriverId) {
      await snapshot.ref.update({driver_id: nearestDriverId});
    }

    // Send notification to the nearest driver
    // (assuming you have a function to retrieve the driver's device token)
    if (nearestDriverId) {
      const driverToken = await getDriverToken(nearestDriverId);
      const notificationPayload = {
        token: driverToken,
        notification: {
          title: "New Booking",
          body: "You have a new booking request",
        },
        data: {
          // Include the booking data as a JSON string
          bookingData: bookingId,
        },
      };

      await sendNotificationToDevice(notificationPayload);
    }
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

export const driverResponse = functions.https.onRequest(async (req, res) => {
  const {driverId, bookingId, response} = req.body;

  const bookingDataSnapshot = await admin.firestore()
    .collection("bookings")
    .doc(bookingId).get();

  if (response === "declined") {
    try {
      const pickupLocation = bookingDataSnapshot.data()?.pick_up_location;

      // Get all online drivers except the one who declined
      const onlineDriversSnapshot = await admin
        .firestore()
        .collection("driver_status")
        .where("status", "==", "online")
        .where("driverId", "!=", driverId)
        .get();

      let nearestDriverId: string | null = null;
      let nearestDriverDistance: number | null = null;

      onlineDriversSnapshot.forEach((driverSnapshot) => {
        const driverData = driverSnapshot.data();
        const driverLocation = {
          latitude: driverData.latitude,
          longitude: driverData.longitude,
        };
        const distance = geolib.getDistance(pickupLocation, driverLocation);

        if (nearestDriverDistance === null ||
          distance < nearestDriverDistance) {
          nearestDriverId = driverSnapshot.id;
          nearestDriverDistance = distance;
        }
      });

      if (nearestDriverId) {
        const driverToken = await getDriverToken(nearestDriverId);
        const notificationPayload = {
          token: driverToken,
          notification: {
            title: "New Booking",
            body: "You have a new booking request",
          },
          data: {
            bookingData: bookingId,
          },
        };
        await sendNotificationToDevice(notificationPayload);
      }

      res.status(200).send("OK");
    } catch (error) {
      console.error("Error:", error);
      res.status(500).send("Error occurred");
    }
  } else if (response === "accepted") {
    try {
      await admin.firestore()
        .collection("driver_status")
        .doc(driverId)
        .update({status: "booked"});

      // Send notification to the passenger
      const passengerToken = bookingDataSnapshot.data()?.passenger_token;
      const notificationPayload = {
        token: passengerToken,
        notification: {
          title: "Driver Found",
          body: "A driver has accepted your booking",
        },
        data: {
          driverId: driverId,
        },
      };
      await sendNotificationToDevice(notificationPayload);

      res.status(200).send("OK");
    } catch (error) {
      console.error("Error:", error);
      res.status(500).send("Error occurred");
    }
  } else {
    res.status(200).send("OK");
  }
});

