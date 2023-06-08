/* eslint-disable max-len */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";

admin.initializeApp();

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
  console.log("Request:", driverId, bookingId, response);

  try {
    const bookingDataSnapshot = await admin.firestore()
      .collection("bookings")
      .doc(bookingId)
      .get();

    console.log("Booking User ID:", bookingDataSnapshot.data()?.user_id);

    if (response === "declined") {
      // Get all online drivers except the one who declined
      const onlineDriversSnapshot = await admin
        .firestore()
        .collection("driver_status")
        .where("status", "==", "online")
        .where(admin.firestore.FieldPath.documentId(), "!=", driverId)
        .get();

      let newDriverId = null;
      let driverTimestamp : number | null = null;
      // Specify the type as 'number | null';

      onlineDriversSnapshot.forEach((driverSnapshot) => {
        const driverData = driverSnapshot.data();
        if (
          driverTimestamp === null ||
          driverData.timestamp < driverTimestamp
        ) {
          newDriverId = driverSnapshot.id;
          driverTimestamp = driverData.timestamp;
        }
      });

      console.log("Nearest Driver ID:", newDriverId);

      if (newDriverId) {
        await bookingDataSnapshot.ref.update({driver_id: newDriverId});

        // Send booking offer to the new driver
        const driverToken = await getDriverToken(newDriverId);
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
    throw new functions.https
      .HttpsError("internal", "Error sending driver response");
  }
});

// Cloud Function to send an email with the provided template
export const sendEmailNotification = functions
  .https
  .onCall(async (data, context) => {
    const {
      receiverEmail,
      receiverName,
      userName,
      location,
      lat,
      lng,
      driverName,
      pickUpTime,
      dropoffTime,
    } = data;

    console.log("ReceiverEmail: " + receiverEmail);
    console.log("receiverName: " + receiverName);
    console.log("userName: " + userName);
    console.log("location: " + location);
    console.log("lat: " + lat + "lng: " + lng);
    console.log("driver_name: " + driverName);
    console.log("pick_up_time: " + pickUpTime);
    console.log("drop_off_time: " + dropoffTime);

    // Convert pick_up_time and drop_off_time to strings
    // const pickUpTimeStr = pickUpTime.toDate().toString();
    // const dropOffTimeStr = dropoffTime.toDate().toString();
    // Create a Nodemailer transporter
    const transporter = nodemailer.createTransport({
      service: "Gmail",
      auth: {
        user: functions.config().gmail.email,
        pass: functions.config().gmail.password,
      },
    });

    // Create the email template
    const emailTemplate = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>Booking Arrival Notification</title>
      <link href='https://fonts.googleapis.com/css?family=Nunito' rel='stylesheet'>
    </head>
    <body style="font-family: 'Nunito'; text-align: center; margin: 0; padding: 20px; background-image: url('https://firebasestorage.googleapis.com/v0/b/tricycallthesis.appspot.com/o/hero-bg.jpg?alt=media&token=72f121ec-7557-48ac-9985-c017c4be7736&_gl=1*10v6lzl*_ga*MTI1NjEyNTMzNy4xNjgzMDEwMDM5*_ga_CW55HF8NVT*MTY4NjA1ODE2NS4xMjEuMS4xNjg2MDU4NjE5LjAuMC4w'); background-size: cover; background-repeat: no-repeat; display: flex; align-items: center; justify-content: center; min-height: 100vh;">
    
      <div class="content" style="background-color: #fff; padding: 20px; 
      border-radius: 10px; display: inline-block; 
      max-width: 90%; box-shadow: 0px 0px 10px rgba(0, 0, 0, 1);">
        <h1 style="color: #000000;">Booking Arrival Notification</h1>
        <p style="color: #333; line-height: 1.5;">
        Dear <span style="font-weight: bold;">Mr./Ms.</span>,</p>
        <p style="color: #333; line-height: 1.5;">
        We are pleased to inform you that 
        <span style="font-weight: bold;">${userName}</span> 
        has successfully arrived at the destination.</p>
        <p style="color: #333; line-height: 1.5; display: flex; 
        align-items: center; justify-content: center;">
          <img src="https://firebasestorage.googleapis.com/v0/b/tricycallthesis.appspot.com/o/source_icon.png?alt=media&token=8bfd9afc-4c8d-4378-ac57-98018d829504&_gl=1*du037c*_ga*MTI1NjEyNTMzNy4xNjgzMDEwMDM5*_ga_CW55HF8NVT*MTY4NjA1ODE2NS4xMjEuMS4xNjg2MDU4MzU2LjAuMC4w" alt="Driver Image" style="width: 20px; margin-right: 10px;"> <span style="font-weight: bold;">${location}</span> <!-- Replace the image path with your actual driver image path -->
        </p>
        <p style="color: #333; line-height: 1.5; display: flex; 
        align-items: center; justify-content: center;">
          <img src="https://firebasestorage.googleapis.com/v0/b/tricycallthesis.appspot.com/o/tricycle_icon.png?alt=media&token=bbe934c0-02f4-4a0b-977d-e728c840ca63&_gl=1*cui6ev*_ga*MTI1NjEyNTMzNy4xNjgzMDEwMDM5*_ga_CW55HF8NVT*MTY4NjA1ODE2NS4xMjEuMS4xNjg2MDU4NDIxLjAuMC4w" alt="Driver Image" style="width: 20px; margin-right: 10px;"> <span style="font-weight: bold;">${driverName}</span> <!-- Replace the image path with your actual driver image path -->
        </p>
        <p style="color: #333; line-height: 1.5;">
        Pick up time: ${pickUpTime} &nbsp;&nbsp;&nbsp; 
        Drop off time: ${dropoffTime}</p>
        <img class="map" src="https://maps.googleapis.com/maps/api/staticmap?center=${lat},${lng}&zoom=15&size=400x300&markers=color:red%7C${lat},${lng}&key=AIzaSyCbYWT5IPpryxcCqNmO_4EyFFCpIejPBf8" alt="Map" style="width: 450px; max-height: auto; margin: 20px 0; box-shadow: 0px 0px 20px rgba(0, 0, 0, 0.5);">
        <p style="color: #333; line-height: 1.5;">
        Thank you for using our service.</p>
        <p style="color: #333; line-height: 1.5;">Sincerely,</p>
        <img class="logo" src="https://firebasestorage.googleapis.com/v0/b/tricycallthesis.appspot.com/o/logo.png?alt=media&token=7ebe7bfc-83fa-49b0-994d-8d40cbb7d444&_gl=1*1ax2obt*_ga*MTI1NjEyNTMzNy4xNjgzMDEwMDM5*_ga_CW55HF8NVT*MTY4NjA1ODE2NS4xMjEuMS4xNjg2MDU4NDc3LjAuMC4w" alt="Logo" style="width: 100px;">
      </div>
    </body>
    </html>
  `;

    // Define the email options
    const mailOptions = {
      from: "tricycall123456@gmail.com",
      to: receiverEmail,
      subject: "Booking Arrival Notification",
      html: emailTemplate,
    };

    try {
    // Send the email
      await transporter.sendMail(mailOptions);
      return {success: true};
    } catch (error: unknown) {
      if (error instanceof Error) {
        console.error("Error sending email:", error);
        return {success: false, error: error.message};
      } else {
        console.error("Unknown error:", error);
        return {success: false, error: "Unknown error occurred."};
      }
    }
  });

exports.sendEmailOnDriverApplication = functions.firestore
  .document("driver_application/{applicationId}")
  .onCreate(async (snapshot, context) => {
    try {
      const applicationData = snapshot.data();
      const email = applicationData.email;
      const firstName = applicationData.first_name;

      // Create a nodemailer transporter with your email service provider credentials
      const transporter = nodemailer.createTransport({
        service: "Gmail",
        auth: {
          user: functions.config().gmail.email,
          pass: functions.config().gmail.password,
        },
      });

      // Define the email template
      const logoImageUrl = "https://example.com/logo.png"; // URL to your logo image
      const greeting = `Hello ${firstName}!`;
      const message = "Thank you for applying. Please wait for your application to be approved.";
      const emailBody = `
        <div>
          <img src="${logoImageUrl}" alt="Tricycall Logo" />
          <h1>${greeting}</h1>
          <p>${message}</p>
        </div>
      `;

      // Define the email options
      const mailOptions = {
        from: "tricycall123456@gmail.com",
        to: email,
        subject: "Application Confirmation",
        html: emailBody,
      };

      // Send the email
      await transporter.sendMail(mailOptions);

      return {success: true};
    } catch (error) {
      console.error("Error sending email:", error);
      throw new functions.https.HttpsError(
        "internal",
        "An error occurred while sending the email."
      );
    }
  });

