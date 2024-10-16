import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../services/dashboard.dart';

class DashboardContentsPage extends StatefulWidget {
  @override
  _DashboardContentsPageState createState() => _DashboardContentsPageState();
}

class _DashboardContentsPageState extends State<DashboardContentsPage> {
  DateRangePickerController _datePickerController = DateRangePickerController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  void _onDateRangeChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      PickerDateRange range = args.value;
      setState(() {
        _startDateController.text =
            DateFormat('yyyy/MM/dd').format(range.startDate!);
        _endDateController.text =
            DateFormat('yyyy/MM/dd').format(range.endDate ?? range.startDate!);
      });
    }
  }

  void _onSearch() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      _showAlertDialog(context, '\n날짜 범위를 설정하세요');
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            message,
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          content: Container(
            width: 300,
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  SfDateRangePicker(
                    controller: _datePickerController,
                    onSelectionChanged: _onDateRangeChanged,
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                      DateTime.now().subtract(Duration(days: 7)),
                      DateTime.now(),
                    ),
                    startRangeSelectionColor: Colors.blueAccent,
                    endRangeSelectionColor: Colors.blueAccent,
                    rangeSelectionColor: Colors.blueAccent.withOpacity(0.2),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(' ~ ', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _endDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month,
                            color: Colors.blueAccent),
                        onPressed: _showDateRangePicker,
                      ),
                    ],
                  )),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    '조 회',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Insta Image',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsInstaImage(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Insta Text',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsInstaText(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Tweet Image',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsTweetImage(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Tweet Text',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsTweetText(),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardContentsInstaImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Insta Image Component'),
    );
  }
}

class DashboardContentsInstaText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Insta Text Component'),
    );
  }
}

class DashboardContentsTweetImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Tweet Image Component'),
    );
  }
}

class DashboardContentsTweetText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Tweet Text Component'),
    );
  }
}
