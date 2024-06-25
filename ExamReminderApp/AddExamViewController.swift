import UIKit
import UserNotifications

class AddExamViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var correctAnswerSegmentedControl: UISegmentedControl!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction private func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    var newExam: ((Exam) -> Void)?
    var errorTimer: Timer?
    private func showErrorLabel() {
            errorLabel.isHidden = false
            errorTimer?.invalidate()
        
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.borderColor = UIColor.red.cgColor
            errorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.hideErrorLabel()
            }
        }
        
        private func hideErrorLabel() {
            errorLabel.isHidden = true
            titleTextField.layer.borderWidth = 0.0
            titleTextField.layer.borderColor = UIColor.clear.cgColor
        }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else {
                    showErrorLabel()
                    return
                }
                
                hideErrorLabel()
        var date = datePicker.date
        
        switch correctAnswerSegmentedControl.selectedSegmentIndex {
        case 0:
            date = date.addingTimeInterval(-15 * 60) // Subtract 15 minutes
        case 1:
            date = date.addingTimeInterval(-30 * 60) // Subtract 30 minutes
        case 2:
            date = date.addingTimeInterval(-60 * 60) // Subtract 1 hour
        case 3:
            date = date.addingTimeInterval(-2 * 60 * 60) // Subtract 2 hours
        default:
            break
        }
        
        let exam = Exam(title: title, date: date)
        newExam?(exam)
        
        scheduleNotification(for: exam)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func scheduleNotification(for exam: Exam) {
        let content = UNMutableNotificationContent()
        content.title = "Sınav Hatırlatıcı"
        content.body =  "'\(exam.title)' isimli Sınavın yaklaşıyor!"
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: exam.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: exam.title, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(exam.title) at \(exam.date)")
            }
        }
    }
}
