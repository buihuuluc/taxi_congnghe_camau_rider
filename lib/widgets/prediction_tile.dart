import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/components/progress_dialogue.dart';
import 'package:uber_clone/models/address.dart';
import 'package:uber_clone/provider/app_data.dart';
import 'package:uber_clone/models/place_predictions.dart';
import 'package:uber_clone/services/network_helper.dart';
import 'package:uber_clone/utils/config_map.dart';

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  const PredictionTile({Key? key, required this.placePredictions})
      : super(key: key);

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const ProgressDialogue(message: 'Vui lòng đợi trong giây lát....'),
    );
    var placeDetails = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');

    var res = await NetworkHelper.getRequest(placeDetails);

    Navigator.pop(context);

    if (res == 'Failed') {
      return;
    }
    if (res['status'] == 'OK') {
      Address address = Address();
      address.placeName = res['result']['name'];
      address.placeId = placeId;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0.0),
      ),
      onPressed: () {
        getPlaceAddressDetails(placePredictions.placeId, context);
      },
      child: Column(
        children: [
          const SizedBox(
            width: 10.0,
          ),
          Row(
            children: [
              const Icon(
                Icons.add_location,
                // color: Colors.yellow,
              ),
              const SizedBox(
                width: 14.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      placePredictions.mainText,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    Text(
                      placePredictions.secondaryText,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
    );
  }
}
