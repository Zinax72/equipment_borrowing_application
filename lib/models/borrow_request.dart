import 'request_status.dart';

class BorrowRequest {
  final String organization;
  final String requester;
  final String email;
  final String contact;
  final String purpose;
  final String date;
  final String returnDate;
  final List<String> equipment;
  RequestStatus status;

  BorrowRequest({
    required this.organization,
    required this.requester,
    required this.email,
    required this.contact,
    required this.purpose,
    required this.date,
    required this.returnDate,
    required this.equipment,
    this.status = RequestStatus.pending,
  });
}
