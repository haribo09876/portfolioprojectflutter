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
  String? _analysisImageDate;
  String? _predictionImageDate;
  bool _isLoading = false;
  bool _isProcessing = false;
  String _statusMessage = '';
  Timer? _waitingTimer;

  @override
  void initState() {
    super.initState();
    _loadLatestImages();
  }

  void _loadLatestImages() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading latest images...';
    });

    try {
      final response = await DashboardService().fetchLatestSalesImages();
      if (!mounted) return;
      setState(() {
        _analysisImageUrl = response['analysisImageURL'];
        _analysisImageDate = response['analysisImageDate'];
        _predictionImageUrl = response['predictionImageURL'];
        _predictionImageDate = response['predictionImageDate'];
        _isLoading = false;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to load images: $e';
      });
    }
  }

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
      _statusMessage = 'Please wait for 5 minutes...';
    });

    try {
      await DashboardService().startSalesProcessingJob(startDate, endDate);

      _waitingTimer = Timer(Duration(minutes: 5), () async {
        try {
          final response = await DashboardService().fetchLatestSalesImages();
          if (!mounted) return;

          setState(() {
            _analysisImageUrl = response['analysisImageURL'];
            _analysisImageDate = response['analysisImageDate'];
            _predictionImageUrl = response['predictionImageURL'];
            _predictionImageDate = response['predictionImageDate'];
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
                      color: Color.fromRGBO(52, 52, 52, 52),
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
                          startRangeSelectionColor: Color(0xFF44558C8),
                          endRangeSelectionColor: Color(0xFF44558C8),
                          rangeSelectionColor:
                              Color(0xFF44558C8).withOpacity(0.2),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF44558C8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: SizedBox(
                            width: 360,
                            child: Center(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
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
                                  color: Color.fromRGBO(52, 52, 52, 52),
                                ),
                              ),
                            ),
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
              _buildDateInputSection(),
              SizedBox(height: 30),
              if (_statusMessage.isNotEmpty)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 30),
                    Center(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(52, 52, 52, 52)),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              _buildSection('Analysis'),
              DashboardSalesAnalysis(
                  imageUrl: _analysisImageUrl,
                  imageDate: _analysisImageDate,
                  isLoading: _isLoading),
              SizedBox(height: 30),
              _buildSection('Prediction'),
              DashboardSalesPrediction(
                  imageUrl: _predictionImageUrl,
                  imageDate: _predictionImageDate,
                  isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInputSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDateController,
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: _inputDecoration('Start date'),
              ),
            ),
            Text(' ~ ', style: TextStyle(fontSize: 18)),
            Expanded(
              child: TextFormField(
                controller: _endDateController,
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: _inputDecoration('End date'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 360,
          child: ElevatedButton(
            onPressed: _showDateRangePicker,
            child: Text(
              'Set dates',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(242, 242, 242, 242),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 360,
          child: ElevatedButton(
            onPressed: _onSearch,
            child: Text(
              'Get results',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF44558C8),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Color(0xFF44558C8),
            width: 1.5,
          ),
        ),
      );

  ButtonStyle _btnStyle(Color color) => ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      );

  Widget _buildSection(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color.fromRGBO(52, 52, 52, 52),
        ),
      );
}

class DashboardSalesAnalysis extends StatelessWidget {
  final String? imageUrl;
  final String? imageDate;
  final bool isLoading;

  DashboardSalesAnalysis(
      {required this.imageUrl,
      required this.imageDate,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : imageUrl != null
            ? Column(
                children: [
                  Image.network(imageUrl!, width: 360),
                  if (imageDate != null)
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          DateFormat('MMM d, yyyy, h:mm a')
                              .format(DateTime.parse(imageDate!).toLocal()),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(52, 52, 52, 52),
                          ),
                        ),
                      ],
                    ),
                ],
              )
            : SizedBox(height: 10);
  }
}

class DashboardSalesPrediction extends StatelessWidget {
  final String? imageUrl;
  final String? imageDate;
  final bool isLoading;

  DashboardSalesPrediction(
      {required this.imageUrl,
      required this.imageDate,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : imageUrl != null
            ? Column(
                children: [
                  Image.network(imageUrl!, width: 360),
                  if (imageDate != null)
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          DateFormat('MMM d, yyyy, h:mm a')
                              .format(DateTime.parse(imageDate!).toLocal()),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(52, 52, 52, 52),
                          ),
                        ),
                      ],
                    ),
                ],
              )
            : SizedBox(height: 10);
  }
}
