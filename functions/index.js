const functions = require("firebase-functions");
const { getFirestore } = require("firebase-admin/firestore");
const admin = require('firebase-admin');
admin.initializeApp();
const db = getFirestore();
// _________________________________________________________
const axios = require('axios');
const path = require('path');
const fs = require('fs');
const os = require('os');
const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
const ffmpeg = require('fluent-ffmpeg');
const ffprobePath = require('@ffprobe-installer/ffprobe').path;
ffmpeg.setFfprobePath(ffprobePath);
ffmpeg.setFfmpegPath(ffmpegPath);
// _________________________________________________________


exports.inferOnVideo = functions.region("australia-southeast1").https.onCall((data, context) => {
  const { videoId } = data;

  fs.writeFileSync(os.tmpdir()+'/test.txt','hello world','utf8');
  let read = fs.readFileSync(os.tmpdir()+'/test.txt','utf8'); // /tmp/test.txt

  db
  .collection("videos")
  .add({
    name: "Tokyo",
    country: "Japan",
    videoId: videoId,
    read: read
  });
});

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
