import './../mixins/medicine_data_decoder.dart';

class Booking {
  String id;
  String idOnServer;
  DateTime dateAndTime;
  String bookingType;
  String doctorName;
  double cost;
  String notes;

  Booking({
    this.id,
    this.dateAndTime,
    this.bookingType,
    this.doctorName,
    this.cost,
    this.notes,
  });

  Booking.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        doctorName = parsedJson['doctorName'],
        dateAndTime =
            MedicineDataDecoder.getDateFromMap(parsedJson['dateAndTime']),
        cost = parsedJson['cost'],
        bookingType = parsedJson['bookingType'],
        notes = parsedJson['notes'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'dateAndTime': {
        'year': dateAndTime.year,
        'month': dateAndTime.month,
        'day': dateAndTime.day,
        'hour': dateAndTime.hour,
        'minute': dateAndTime.minute
      },
      'cost': cost,
      'bookingType': bookingType,
      'notes': notes,
    };
  }
}
