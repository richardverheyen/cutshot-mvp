const functions = require("firebase-functions");
const { getFirestore } = require("firebase-admin/firestore");
const admin = require('firebase-admin');

admin.initializeApp();
const db = getFirestore();

exports.cleanStorageOnDelete = functions
  .region("australia-southeast1")
  .firestore.document("videos/{videoId}")
  .onDelete((change, context) => {
    const { videoId } = context.params;

    const storageRef = admin.storage().bucket();
    const options = {
      prefix: `${videoId}/`
    };
    storageRef.deleteFiles(options);
  });

exports.finaliseVideoUpload = functions
  .region("australia-southeast1")
  .storage.object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const documentName = filePath.split("/").shift();
    const fileName = filePath.split("/").pop();

    if (fileName === "thumbnail") {
      db.collection("videos").doc(documentName).update({
        thumbnailStored: true,
      });
    } else if (fileName === "video") {
      db.collection("videos").doc(documentName).update({
        videoStored: true,
      });
    }
  });
