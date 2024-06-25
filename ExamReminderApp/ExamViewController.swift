import UIKit

class ExamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var exams: [Exam] = []
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExamCell")
        loadExams()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkForOverdueExams), userInfo: nil, repeats: true)

    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            timer?.invalidate()
            timer = nil
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddExamSegue",
           let addExamVC = segue.destination as? AddExamViewController {
            addExamVC.newExam = { [weak self] exam in
                self?.exams.append(exam)
                self?.saveExams()
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamCell", for: indexPath)
        let exam = exams[indexPath.row]
        let timeLeft = timeLeftUntil(exam.date)
        cell.textLabel?.text = "\(exam.title) - \(timeLeft)"
        
        return cell
    }
    @objc private func checkForOverdueExams() {
            let currentDate = Date()
            exams = exams.filter { $0.date > currentDate }
            saveExams()
            tableView.reloadData()
        }
    private func timeLeftUntil(_ date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "Sınav Bitti"
        }
        
        let days = Int(timeInterval / (60 * 60 * 24))
        let hours = Int((timeInterval.truncatingRemainder(dividingBy: 60 * 60 * 24)) / (60 * 60))
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 60 * 60)) / 60)
        
        if days > 0 {
            return "\(days) gün kaldı"
        } else if hours > 0 {
            return "\(hours) saat kaldı"
        } else {
            return "\(minutes) dakika kaldı"
        }
    }
    
    // Enable swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exams.remove(at: indexPath.row)
            saveExams()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Persistence

    private func saveExams() {
        let examsData = exams.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(examsData, forKey: "exams")
    }

    private func loadExams() {
        guard let savedExamsData = UserDefaults.standard.array(forKey: "exams") as? [Data] else { return }
        exams = savedExamsData.compactMap { try? JSONDecoder().decode(Exam.self, from: $0) }
    }
}
