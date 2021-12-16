import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CollectFareDialog extends StatelessWidget
{
  final String paymentMethod;
  final int fareAmount;


  CollectFareDialog(
      { required this.paymentMethod, required this.fareAmount,} );
  @override
  Widget build(BuildContext context) {
    return Dialog(
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

            Text("Số Tiền Chuyến Đi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),),

            SizedBox(height: 12.0,),

            Divider(height: 2.0, thickness: 2.0,),

            SizedBox(height:16.0),

            Text(
                NumberFormat.currency(locale: 'vi', decimalDigits: 0).format(fareAmount),
              style: TextStyle(fontSize: 50.0,fontFamily: "Brand-Bold"),),
            SizedBox(height: 16.0,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("Đây là tổng số tiến của chuyến đi, nó đã được tính cho khách hàng.", textAlign: TextAlign.center,),
            ),

            SizedBox(height: 30.0,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: RaisedButton(
                onPressed: () async
                {
                  Navigator.pop(context, 'close');

                },
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Trả Tiền",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.white,),),
                      Icon(Icons.attach_money,color: Colors.white,size: 26.0,),
                    ],
                  ),
                ),

              ),
            ),
            SizedBox(height: 30.0,),
          ],
        ),
      ),
    );
  }
}