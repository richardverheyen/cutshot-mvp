const axios = require('axios');
const functions = require("firebase-functions");
const { getFirestore } = require("firebase-admin/firestore");
const admin = require('firebase-admin');
var serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = getFirestore();

exports.inferOnVideo = functions.region("australia-southeast1").https.onCall(async (data, context) => {
  const { thumbnailPaths } = data;

  try {
    let urls = await Promise.all(thumbnailPaths.map(async (appPath) => {
      let split = appPath.split("/");
      let str = split.pop();
      let path = split.pop() + "/" + str;
      console.log("path", path);
      
      return admin.storage().bucket("gs://cutshot-35dae.appspot.com").file(path).getSignedUrl({
        action: 'read',
        expires: Date.now() + 60 * 60 * 1000, // 10 minutes
        private: false
      });
    })); 

    console.log({urls});

    const results = await Promise.all(urls.flat().map(url => {
      return new Promise((res, rej) => {
        axios({
          method: "POST",
          url: "https://detect.roboflow.com/mikasa-portrait/2",
          params: {
              api_key: "Sdds35HYt1hTznk1WWSS",
              image: url
          }
        }).then((response) => {
          console.log(response.data);
          res(response.data);
        }).catch((error) => {
          console.log(error);
          rej(error);
        });
      });
      
    }));

    console.log({results});

    await db.collection("videos").add({
      name: "Tokyo",
      country: "Japan",
      results: results
    });

    return { success: true };
  } catch (error) {
    console.error(error);
    return { success: false, error: error.message };
  }
});

https://storage.googleapis.com/cutshot-35dae.appspot.com/Ds7Vf0EIiElWnRopvYk0/thumbnail-1.png?GoogleAccessId=firebase-adminsdk-b9zns%40cutshot-35dae.iam.gserviceaccount.com&Expires=1680827175&Signature=D3FyY9IB3yJe0K9wubqRmQtHRUaYwyHioRBXjwd67SS9StJoGqZnqFRaeSXPFULJFqaISXuXhtY9Ree42iG%2FMufJ8yRZjDQhNdz1ya%2Bgkrv9yJ9keZf6aEVv83XdKJPeohX7WxR%2FUCCb%2F2zBsA6QMJBoIz%2FDdJVtW3pidK7bQsEFDYKtbbGyBjNXrK%2Fm0cTytOQwviEWhWcQ7PON2o%2FwNDFTp7Rd3S2oYUFgHmOmyfvJ90iD9jAvrkAJuB1ZaW0d%2BabcBRQr6JmoTAz5u4uzbgJKGxceWYnhrXtKC4WzvbRYAD3Qgxz6mS%2BDrdLIcqUIqBtZAhCsgU2AbwOURdH2rw%3D%3D

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
