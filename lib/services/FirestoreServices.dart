
import 'dart:developer';


import 'package:EMallApp/models/DeliveryBoy.dart';
import 'package:EMallApp/models/DeliveryDistanceModel.dart';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class FirestoreServices{

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('drivers');

       double distance=0;

    Future<List<DeliveryBoy>> getAllAvaiableDrivers(bool isWater)async {

          List<DeliveryBoy> deliveries =[];

        try{
          var ds;
          if(isWater){
             ds = await collection.where("isOffline" ,isEqualTo: false).where("shop_id" ,isNotEqualTo: 0).get();

             log("water deliveries: "+ds.toString());
          }else{
            
             ds = await collection.where("isOffline" ,isEqualTo: false).where("shop_id" ,isEqualTo:0).get();
              log("gas deliveries: "+ds.toString());
          }
       

       if(ds.docs.isEmpty){
         
         log("No Drivers We Must Show Pop up first to the user let him know that there is no drivers right now");
         

      
       }else{

          ds.docs.forEach((element) {
              deliveries.add(DeliveryBoy.fromJson(element.data() as Map<String, dynamic>));
          },);
          log(deliveries.length.toString());
       }

       }catch(e){
          return [];
       }
       return deliveries;

  }

      Future<DeliveryBoy?> getDeliveryBoy(id)async {

      DeliveryBoy? delivery;

        try{
       var ds = await collection.where("id" ,isEqualTo: id).get();

       if(ds.docs.isEmpty){
         
         log("No Drivers We Must Show Pop up first to the user let him know that there is no drivers right now");
         

      
       }else{

        
            delivery=  DeliveryBoy.fromJson(ds.docs.first.data() as Map<String, dynamic>);

            log(delivery.name.toString());
    
        
       }

       }catch(e){
          return delivery;
       }
       return delivery;

  }

  Future<List<DeliveryBoy>> getNearestFiveDrivers(List<DeliveryBoy> deliveries,UserAddress userAddress)async{

    List<DeliveryBoy> nearestDeliveries =[];
    List<DeliveryDistanceModel> nearestDeliveriesDistance =[];

   

    if(deliveries.length==0){
        distance=-1;
    }
   else{

    await  Future.wait(deliveries.map((delivery) async{


            

        double distance =   await  getDistanceBetweenTwoPoints(delivery.latitude!,delivery.longitude!,userAddress.latitude,userAddress.longitude );

       log("near delivey: "+distance.toString());
        DeliveryDistanceModel deliveryDistanceModel = DeliveryDistanceModel(delivery, distance);

        nearestDeliveriesDistance.add(deliveryDistanceModel);


     }));
        
         log("nearest deliveries: "+nearestDeliveriesDistance.toString());

         nearestDeliveriesDistance.sort((a, b) => a.distance.compareTo(b.distance));
      

        List<DeliveryDistanceModel> leastDistanceFiveValues = nearestDeliveriesDistance.take(5).toList();

        if(leastDistanceFiveValues.length > 0){
          log(leastDistanceFiveValues[0].distance.toString());
          distance =leastDistanceFiveValues[0].distance;
          
        }else{
          distance = -1;
        }

        leastDistanceFiveValues.forEach((element) {
          nearestDeliveries.add(element.deliveryBoy);
          log(element.distance.toString());
        });
         
    }
    return nearestDeliveries;

  }



  getDistanceBetweenTwoPoints(double lat1,double lang1,double lat2 , double lang2){
    double distance = Geolocator.distanceBetween(lat1,  lang1, lat2, lang2);


    return distance;

  }

    Future<DocumentReference> addDelivery(DeliveryBoy deliveryBoy,{double lat=0.0,double long=0.0}) {

    
    return collection.add(deliveryBoy.toMap());
  }

     updateLatLong(DeliveryBoy deliveryBoy,{double lat=0.0,double long=0.0})async {

       var ds = await collection.where("id" ,isEqualTo: deliveryBoy.id).get();
        await collection.doc(ds.docs.first.id).update({
            "lat" : lat,
            "long":long,
        });


}

}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ordertracking/core/networking/constants.dart';
// import 'package:ordertracking/models/order_model_firebase.dart';
// import 'package:ordertracking/models/orders_model.dart';

// class FirebaseRepo {
//   // 1
//   final CollectionReference collection =
//       FirebaseFirestore.instance.collection('orders');
//   // 2
//   Stream<QuerySnapshot>? getStream() {

//     try{
//        return collection.snapshots();
//     }catch(e){
//       print("i am in error");
//       print(e.toString());

//     }
   
//    return null;
//   }

//     Stream<QuerySnapshot> getStreamForDriver(driverId) {
//     return collection.where("driver_id",isEqualTo: driverId).snapshots();
//   }

//    sendLongAndLatitudeToFirebase(OrderModel order,String latitude,String longitude)async {

//        var ds = await collection.where("id" ,isEqualTo: order.id).where("tracking_number",isEqualTo: order.trackingNumber).get();
//         await collection.doc(ds.docs.first.id).update({
//             "driver_latitude" : latitude,
//             "driver_longitude":longitude,
//         });
      
//     print("supposed done");
//     //return collection.add(order.toMap());
//   }


//      changeFirebaseOrderStatus(OrderModel order,int active,int status)async {

//        var ds = await collection.where("id" ,isEqualTo: order.id).where("tracking_number",isEqualTo: order.trackingNumber).get();
//         await collection.doc(ds.docs.first.id).update({
//             "active" : active,
//             "status":status,
//         });
      
//     print("supposed done");
//     //return collection.add(order.toMap());
//   }



//     Future<OrderModelFirebase> checkOrdersIsExistsAndCreate(OrderModel order)async {

//        var ds = await collection.where("id" ,isEqualTo: order.id).where("tracking_number",isEqualTo: order.trackingNumber).get();

//        if(ds.docs.isEmpty){
//          OrderModelFirebase orderModelFirebase= OrderModelFirebase(active: 0,id: order.id,driverId: order.driverId,
//          mobile: order.mobile,latitude: order.latitude,longitude: order.longitude,
//          driverLat: "0.00",driverLon: "0.00",status: order.status,
//          trackingNumber: order.trackingNumber,
//          createdAt: order.createdAt,
//          updatedAt: order.updatedAt,
//          driverName: Constants.user!.name,
//          driverPhone: Constants.user!.phone,
//          driverImage: Constants.user!.image,
//          carNumber: Constants.user!.carNumber,
//          );
//          addOrder(orderModelFirebase);

//          return orderModelFirebase;
//        }else{
//           return OrderModelFirebase.fromMap(  ds.docs.first.data() as Map<String, dynamic>);
//        }
//     print(ds.docs.first.data());
//     //return collection.add(order.toMap());
//   }



//     Future<OrderModelFirebase?> checkTrackingNumberExists(String trackingNumber)async {

//        var ds = await collection.where("tracking_number",isEqualTo: trackingNumber).get();

//        if(ds.docs.isEmpty){
//          return null;
//        }else{
//           return OrderModelFirebase.fromMap(  ds.docs.first.data() as Map<String, dynamic>);
//        }
    
//     //return collection.add(order.toMap());
//   }



  
//   // 3
//   Future<DocumentReference> addOrder(OrderModelFirebase order) {

    
//     return collection.add(order.toMap());
//   }
//   // 4
//   void updateOrder(OrderModelFirebase order) async {
//     await collection.doc(order.trackingNumber).update(order.toMap());
//   }
//   // 5
//   void deleteOrder(OrderModelFirebase order) async {
//     await collection.doc(order.trackingNumber).delete();
//   }
// }