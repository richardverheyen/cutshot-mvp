const functions = require("firebase-functions");

exports.generateThumbnail = functions.region("australia-southeast1").storage.object().onFinalize(async (object) => {
    const filePath = object.name;
    const documentName = filePath.split('/').shift();
    const fileName = filePath.split('/').pop();

    if (fileName === 'thumbnail') {
        functions.firestore.document(`videos/${documentName}`).update({
            thumbnail: filePath
        });
    } else if (fileName === 'video' ) {
        functions.firestore.document(`videos/${documentName}`).update({
            storageFinalised: true
        });
    }

});
