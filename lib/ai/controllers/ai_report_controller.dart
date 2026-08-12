import 'package:get/get.dart';

class AiReportController extends GetxController {
  /// Selected question from dropdown
  final RxString selectedQuestion = 'Overall business report'.obs;

  /// Generated AI report
  final RxString report = ''.obs;

  /// Loading state
  final RxBool loading = false.obs;

  /// Dropdown questions
  final List<String> questionOptions = [
    'Overall business report',
    'Popular sale items',
    'VIP customers by amount',
    'Low stock products',
    'Expense control suggestions',
  ];

  /// Change selected question
  void setQuestion(String question) {
    selectedQuestion.value = question;
  }

  /// Save generated report
  void setReport(String value) {
    report.value = value;
  }

  /// Change loading state
  void setLoading(bool value) {
    loading.value = value;
  }

  /// Clear report if needed
  void clearReport() {
    report.value = '';
  }
}