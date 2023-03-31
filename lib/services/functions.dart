import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  final inferOnVideo =
      FirebaseFunctions.instanceFor(region: 'australia-southeast1')
          .httpsCallable('inferOnVideo')
          .call;
}
