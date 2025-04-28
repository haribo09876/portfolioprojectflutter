import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:async';
import '../services/dashboard.dart';

class DashboardSalesPage extends StatefulWidget {
  @override
  _DashboardSalesPageState createState() => _DashboardSalesPageState();
}

class _DashboardSalesPageState extends State<DashboardSalesPage> {
  DateRangePickerController _datePickerController = DateRangePickerController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  String? _analysisImageUrl;
  String? _predictionImageUrl;
  bool _isLoading = false;
  bool _isProcessing = false;
  String _statusMessage = '';
  Timer? _waitingTimer;

  @override
  void dispose() {
    _waitingTimer?.cancel();
    super.dispose();
  }

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
      _showAlertDialog(context, '\nSet the date range');
    } else {
      if (_isProcessing) return;
      _startSalesProcessing();
    }
  }

  void _startSalesProcessing() async {
    final startDate = DateFormat('yyyy/MM/dd').parse(_startDateController.text);
    final endDate = DateFormat('yyyy/MM/dd').parse(_endDateController.text);

    setState(() {
      _isLoading = true;
      _isProcessing = true;
      _statusMessage = 'Processing started. Please wait for 5 minutes...';
    });

    try {
      await DashboardService().startSalesProcessingJob(startDate, endDate);

      _waitingTimer = Timer(Duration(minutes: 5), () async {
        try {
          final response = await DashboardService().fetchLatestSalesImages();
          if (!mounted) return;

          setState(() {
            _analysisImageUrl = response['analysisImageURL'];
            _predictionImageUrl = response['predictionImageURL'];
            _isLoading = false;
            _isProcessing = false;
            _statusMessage = '';
          });
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _isProcessing = false;
            _statusMessage = '';
          });
          _showAlertDialog(context, 'Data loading failure: $e');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isProcessing = false;
        _statusMessage = '';
      });
      _showAlertDialog(context, 'Failed to start processing job: $e');
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Error alert',
            style: TextStyle(fontSize: 20),
          ),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                message,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(242, 242, 242, 242),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(52, 52, 52, 1),
                    ),
                  ),
                ),
              ),
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
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Date range setting',
            style: TextStyle(fontSize: 20),
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          rangeSelectionColor:
                              Colors.blueAccent.withOpacity(0.2),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: SizedBox(
                            width: 360,
                            child: Center(child: Text('Confirm')),
                          ),
                        ),
                        SizedBox(height: 5),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(242, 242, 242, 242),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(child: Text('Cancel')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Start Date',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Color(0xFF44558C8), width: 1.5),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Text(' ~ ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'End Date',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Color(0xFF44558C8), width: 1.5),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isProcessing ? null : _showDateRangePicker,
                child: Text('Set Date Range'),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: _isProcessing ? null : _onSearch,
                child: Text('Get Results'),
              ),
              SizedBox(height: 20),
              if (_statusMessage.isNotEmpty)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(_statusMessage),
                    SizedBox(height: 20),
                  ],
                ),
              Text('Analysis',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              DashboardSalesAnalysis(
                imageUrl: _analysisImageUrl,
                isLoading: _isLoading,
              ),
              SizedBox(height: 20),
              Text('Prediction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              DashboardSalesPrediction(
                imageUrl: _predictionImageUrl,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardSalesAnalysis extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;

  DashboardSalesAnalysis({required this.imageUrl, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : imageUrl != null
            ? Image.network(imageUrl!)
            : SizedBox(height: 10);
  }
}

class DashboardSalesPrediction extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;

  DashboardSalesPrediction({required this.imageUrl, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : imageUrl != null
            ? Image.network(imageUrl!)
            : SizedBox(height: 10);
  }
}
