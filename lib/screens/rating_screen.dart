import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:uber_clone/utils/config_map.dart';


class RatingScreen extends StatefulWidget
{
  final String driverId;

  RatingScreen({required this.driverId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22.0,),

              Text(
                "Đánh giá tài xế",
                style: TextStyle(fontFamily: "Brand Bold", fontSize: 23, color: Colors.black, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 12.0,),

              Divider(height: 2.0, thickness: 2.0,),

              SizedBox(height:16.0),

              SmoothStarRating(
                rating: starCounter,
                color: Colors.yellow,
                allowHalfRating: false,
                starCount: 5,
                size: 45,
                onRatingChanged: (value)
                {
                  starCounter = value;
                  setState(() {
                    if(starCounter == 1)
                    {
                      setState(() {
                        title = "Rất tệ";
                      });
                    }
                    if(starCounter == 2)
                    {
                      setState(() {
                        title = "Khá tệ";
                      });
                    }
                    if(starCounter == 3)
                    {
                      setState(() {
                        title = "Tạm được";
                      });
                    }
                    if(starCounter == 4)
                    {
                      setState(() {
                        title = "Khá tốt";
                      });
                    }
                    if(starCounter == 5)
                    {
                      setState(() {
                        title = "Rất tốt";
                      });
                    }
                  });



                },
              ),

              SizedBox(height: 15.0,),

              Text(title, style: TextStyle(fontSize: 55.0, fontFamily: "Signatra", color: Colors.black),),

              SizedBox(height: 16.0,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: RaisedButton(
                  onPressed: () async
                  {
                    DatabaseReference? driverRatingRef = FirebaseDatabase.instance.reference()
                        .child('Drivers')
                        .child(widget.driverId)
                        .child('ratings');

                    driverRatingRef.once().then((DataSnapshot snap){
                      if(snap.value != null)
                      {
                        double oldRatings = double.parse(snap.value.toString());
                        double addRatings = oldRatings + starCounter;
                        double averageRatings = addRatings/2;
                        driverRatingRef.set(averageRatings.toString());
                      }
                      else
                        {
                          driverRatingRef.set(starCounter.toString());
                        }
                    });

                    Navigator.pop(context);

                  },
                  color: Colors.black,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Đánh giá",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.white,),),

                      ],
                    ),
                  ),

                ),
              ),
              SizedBox(height: 30.0,),
            ],
          ),
        ),
      ),
    );
  }
}